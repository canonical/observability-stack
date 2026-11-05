---
myst:
  html_meta:
    description: "Control metric cardinality in Mimir: diagnose high-cardinality series, filter and aggregate at the OpenTelemetry Collector, and tune Mimir limits to avoid OOM."
---

# How to control metric cardinality in Mimir

```{note}
**Availability markers used in this guide**

- `[charm]` — configurable via `juju config` on the coordinator today.
- `[future]` — not yet exposed by the charm. Placeholder; do not rely on it until the charm option lands.
- `[collector]` — applied to your own OpenTelemetry collectors, outside the charm.
```

```{note}
This guide uses Mimir for concrete examples. The collector-side guidance (section 3)
applies equally to Prometheus in COS Lite, and the general principles are the same.
Mimir-specific parts are the cardinality API endpoints and the `cortex_ingester_*`
metrics; Prometheus exposes `prometheus_tsdb_head_series` and has no equivalent
cardinality API.
```

## The one idea

Mimir's ingester memory is dominated by the **number of distinct time series** held in the TSDB head, not by samples/second. A series is one unique combination of metric name + label values. Every new combination costs memory (index entry, postings, head chunks) for as long as it lives in the head.

Consequences:

- Throughput (samples/s) is cheap; cardinality (distinct series) is expensive.
- The series count is the number of **observed** label combinations, bounded above by the product of each label's value count — but usually far below it.
- To accept more data without OOM, reduce distinct series or add memory.

## Control points (three layers)

1. **Collector (best):** drop/aggregate before data leaves the collector. `[collector]`
2. **Mimir (defensive):** cap series and rate-limit to protect the ingesters from the cardinality that still arrives. (Partly `[future]` — see {ref}`harden-mimir`.)
3. **Capacity (last resort):** more memory / more ingesters.

## 1. Prerequisites: enable the cardinality tooling

### Enable the cardinality API

`[charm]` The coordinator exposes a `cardinality_analysis_enabled` option (default `false`). Enable the API with:

```bash
juju config <coordinator-app> cardinality_analysis_enabled=true
```

Once enabled, use the endpoints below.

### API endpoints

Base: `https://<query-frontend>:8080/prometheus/api/v1/cardinality` (the Prometheus HTTP prefix defaults to `/prometheus`), served by the query-frontend/querier. Available once the option above is enabled. Send the `X-Scope-OrgID: <tenant>` header (use `anonymous` when multitenancy is disabled).

| Path | Purpose |
|---|---|
| `.../label_names` | distinct value count per label name |
| `.../label_values` | series count per label value |
| `.../active_series` | label sets of active series |
| `.../active_native_histogram_metrics` | native histogram metric names |

Parameters: `selector`, `label_names[]`, `count_method=inmemory|active`, `limit`.

```bash
curl -g -sk 'https://<query-frontend>:8080/prometheus/api/v1/cardinality/label_values?label_names[]=job&selector={__name__=~".*"}&count_method=inmemory&limit=100' \
  -H 'X-Scope-OrgID: anonymous'
```

The remaining examples in this guide use `.../` for the base above.

`count_method`:

- `inmemory` — series in the ingester TSDB head (what consumes memory; what `max_global_series_per_user` counts).
- `active` — only series with a sample within the active-series idle timeout (default 20m).

### Dashboards

- TODO: Mention the Cardinality dashboard once merged and released ...

## 2. Diagnose: series forensics

Work **job → metric → label → value**. Requires the API from the previous section.

1. Which source job?

```bash
.../label_values?label_names[]=job&selector={__name__=~".*"}&count_method=inmemory&limit=100
```

2. Which metric within the job?

```bash
.../label_values?label_names[]=__name__&selector={job="kubelet"}&count_method=inmemory&limit=30
```

3. Which labels multiply that metric? (`label_names` with a narrow selector returns the distinct-value count of every label on that metric)

```bash
.../label_names?selector={__name__="apiserver_request_duration_seconds_bucket"}&count_method=inmemory
```

4. Which value dominates?

```bash
.../label_values?label_names[]=resource&selector={__name__="apiserver_request_duration_seconds_bucket"}&count_method=inmemory&limit=20
```

Rules:

- Rank by **series per value**, never by distinct-value count. A label with 20k values can carry 2% of series; a label with 600 values can carry 99%.
- For a label with `D` distinct values that co-occurs broadly, aggregating it away roughly divides the metric's series by `D`.
- Histograms: the `le` label multiplies by the bucket count; `_sum`/`_count` add two more series per combination.

## 3. Remediate at the collector `[collector]`

These are applied to your own OpenTelemetry collectors, not the charm. See also
[Selectively drop telemetry using opentelemetry-collector](selectively-drop-telemetry-otelcol.md)
and [Selectively drop telemetry using scrape config](selectively-drop-telemetry-scrape-config.md).

### 3.1 Drop metric families / histograms (`filter` processor)

Drop whole metric families by name, or every histogram at once. The prometheus receiver folds a classic histogram into a single OTLP histogram metric named after the base (for example `apiserver_request_duration_seconds`), so match the base name here — there is no `_bucket` suffix at this point (see 3.2 for dropping buckets by name).

Modern (collector ≥ 0.146):

```yaml
processors:
  filter/drop_unused:
    error_mode: ignore
    metric_conditions:
      # Drop specific families by base name, e.g. every kubelet metric
      - 'IsMatch(metric.name, "^kubelet_")'
      # Or drop every histogram metric
      - 'metric.type == METRIC_DATA_TYPE_HISTOGRAM'
```

Older collectors:

```yaml
processors:
  filter/drop_unused:
    error_mode: ignore
    metrics:
      metric:
        - 'IsMatch(name, "^kubelet_")'
        - 'type == METRIC_DATA_TYPE_HISTOGRAM'
```

Scope by job (the prometheus receiver maps `job` → resource attribute `service.name`; older builds may use `job`):

```yaml
- 'resource.attributes["service.name"] == "kubelet" and type == METRIC_DATA_TYPE_HISTOGRAM'
```

### 3.2 Drop only buckets, keep `_sum`/`_count` (`metric_relabel_configs`)

At scrape time the series are still `_bucket`/`_sum`/`_count`:

```yaml
receivers:
  prometheus:
    config:
      scrape_configs:
        - job_name: apiserver
          metric_relabel_configs:
            - source_labels: [__name__]
              regex: '.*_bucket'
              action: drop
```

### 3.3 Aggregate away high-cardinality labels (`metricstransform`)

```yaml
processors:
  metricstransform/aggregate:
    transforms:
      - include: apiserver_request_duration_seconds
        action: aggregate_labels
        label_set: [scope]        # labels to KEEP; everything else is summed away
        aggregation_type: sum     # only sum is supported for histograms
```

### 3.4 Reduce histogram buckets

Keep only the `le` values you query. This divides every histogram family by the ratio of buckets kept/dropped and is less destructive than dropping the whole family.

### 3.5 Verify at the source

```bash
curl -s localhost:8888/metrics | grep -E 'processor="filter/<id>"'
```

`otelcol_processor_incoming_items` vs `otelcol_processor_outgoing_items`: `in > out` means the filter is dropping. (Items = data points, not Mimir series.)

(harden-mimir)=

## 4. Harden Mimir with defensive limits

Reducing cardinality (dropping or aggregating metrics and labels) belongs in the
collector (section 3), which COS and COS Lite always deploy alongside Prometheus and
Mimir. This section is about protecting Mimir from the cardinality that still arrives:
caps and rate limits that keep the ingesters within their memory budget instead of being
OOM-killed.

### 4.1 Per-tenant caps

- `[charm]` **`max_global_series_per_user`** — cap in-memory series per tenant. Rejects
  excess (4xx). Default `0` (disabled) in the charm; Mimir's own default is `150000`.
- `[future]` **`max_global_series_per_metric`** — cap series per metric name; contains a
  single runaway metric.
- `[charm]` **`ingestion_rate`** — per-tenant samples/s limit. Throughput only; it does
  not reduce cardinality.
- `[future]` **`max_label_names_per_series`** (default 30) /
  **`max_label_value_length`** (default 2048) — bound per-series cost.

### 4.2 Read-path guards

- `[future]` **`-querier.max-fetched-chunks-per-query`** (default 2,000,000) /
  **`-querier.max-fetched-series-per-query`** (default 0) — prevent a single huge metric
  from making queries fail or exhausting the querier.

### 4.3 Idle TSDBs

- `[future]` **`-blocks-storage.tsdb.close-idle-tsdbs-after`** — close idle tenant TSDBs
  to free memory.

## 5. Capacity

- Memory ≈ distinct series × per-series cost (a few KB; label/chunk density dependent).
- With `N` ingesters and replication factor `RF`, per-ingester series ≈ `D × RF / N` (for `N ≥ RF`).
- Scaling out lowers per-ingester memory for the same `D`; scaling up adds per-ingester headroom.
- Headroom: `(limit − current) / current` is the fraction more series you can hold.
- For the portion that is genuine scale (many sources, each with a stable series count), capacity is the correct answer; filtering is not.

## 6. Verify

- `cortex_ingester_memory_series` (per ingester, no `user` label)
- `cortex_ingester_memory_series_created_total{user}` / `_removed_total{user}` (per tenant; `created − removed` = in-memory series)
- `cortex_ingester_active_series{user}`
- `cortex_ingester_owned_series{user}`
- `cortex_discarded_samples_total{reason}` (why data is rejected)
- `cortex_ingester_instance_limits{limit=...}`
- Cardinality API `series_count_total`
- Collector `:8888/metrics` in/out

## 7. Related guides

- [Evaluate telemetry volume](evaluate-telemetry-volume.md)
- [Selectively drop telemetry using scrape config](selectively-drop-telemetry-scrape-config.md)
- [Selectively drop telemetry using opentelemetry-collector](selectively-drop-telemetry-otelcol.md)
- [Configure memory limits for the OpenTelemetry Collector](configure-memory-limits-otelcol.md)

## 8. Upstream docs

- Mimir HTTP API (cardinality endpoints): https://grafana.com/docs/mimir/latest/references/http-api/
- Mimir configuration parameters (limits): https://grafana.com/docs/mimir/latest/configure/configuration-parameters/#limits
- Mimir capacity planning: https://grafana.com/docs/mimir/latest/manage/run-production-environment/planning-capacity/
- Mimir runbooks: https://grafana.com/docs/mimir/latest/manage/mimir-runbooks/
- GEM cardinality management: https://grafana.com/docs/enterprise-metrics/latest/manage/tenant-management/cardinality-management/
- OTel filter processor: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/filterprocessor
- OTel metricstransform processor: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/metricstransformprocessor
- OTel prometheus receiver: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/prometheusreceiver
- OTel prometheusremotewrite exporter: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/prometheusremotewriteexporter
- Prometheus relabeling: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config
- Grafana cardinality management dashboard: https://play.grafana.org/d/f0b9f49d-6652-4a3f-8025-20f65a6b0541/

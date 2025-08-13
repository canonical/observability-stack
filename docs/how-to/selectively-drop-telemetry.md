# Selectively drop telemetry

Sometimes, from a resource perspective, applications are instrumented with more telemetry than we want to afford. In such cases, we can choose to selectively drop some before they are ingested.

## Inspect the received telemetry
The telemetry format of the OpenTelemetry Collector (otelcol) is defined by the OpenTelemetry Protocol (OTLP) with [example JSON files for all signals](https://github.com/open-telemetry/opentelemetry-proto/blob/main/examples/README.md). In OTLP, data is organized hierarchically:

```
LogsData -> ResourceLogs -> ScopeLogs -> LogRecord
MetricsData -> ResourceMetrics -> ScopeMetrics -> Metric
TracesData -> ResourceSpans -> ScopeSpans -> Span
```

Generally speaking, `Data` is a collection of `Resource` items associated with specific resources such as a specific service or host.  Each `Resource` contains information about itself and multiple `Scope` items, for grouping based on their `InstrumentationScope` (the library or component responsible for generating the telemetry). The `LogRecord`, `Metric`, and `Span` are the core building blocks of the respective telemetry that represents a single operation or activity.

Using the [debug exporter with normal verbosity](https://github.com/open-telemetry/opentelemetry-collector/tree/main/exporter/debugexporter#normal-verbosity), enabled per telemetry type, we can inspect the signals which make it through the pipeline.

```yaml
exporters:
  debug:
    verbosity: normal
service:
  pipelines:
    logs:
      exporters:
        - debug
    metrics:
      exporters:
        - debug
    traces:
      exporters:
        - debug
```

This allows us to understand the structure of the signal's resources and attributes prior to crafting our filtering. Before reaching an exporter, a signal is first processed by a processor and any modification to signals are propagated throughout the remainder of the pipeline. You can check the charm's debug exporter output with the command: `juju ssh --container otelcol OTELCOL_APP/0 "pebble logs -f"`. 

### Metrics
A metric signal flowing through the pipeline will look similar to:
```shell
ResourceMetrics #0 service.name=otelcol server.address=how-to_7b30903e_otelcol_otelcol/0 service.instance.id=299818a5-2dab-43e2-a6a5-015bab12cc75 server.port= url.scheme=http juju_application=otelcol juju_charm=opentelemetry-collector-k8s juju_model=how-to juju_model_uuid=7b30903e-8941-4a40-864c-0cbbf277c57f juju_unit=otelcol/0 service.version=0.130.1
ScopeMetrics #0 github.com/open-telemetry/opentelemetry-collector-contrib/receiver/prometheusreceiver@0.130.1
scrape_samples_post_metric_relabeling{juju_application=otelcol,juju_charm=opentelemetry-collector-k8s,juju_model=how-to,juju_model_uuid=7b30903e-8941-4a40-864c-0cbbf277c57f,juju_unit=otelcol/0} 17
```

### Logs
A log signal flowing through the pipeline will look similar to:
```shell
ResourceLog #0 loki.format=raw
ScopeLog #0
{"host":"173.119.110.173", "user-identifier":"-", "datetime":"11/Aug/2025:07:06:45 +0000", "method": "GET", "request": "/interactive/synthesize/monetize/best-of-breed", "protocol":"HTTP/2.0", "status":200, "bytes":16850, "referer": "http://www.internalback-end.com/syndicate", "message": "saepe assumenda non expedita ... corporis corporis facilis quo sit cumqu"} juju_unit=flog/0 filename=/bin/fake.log job=juju_how-to_7b30903e_flog juju_application=flog juju_charm=flog-k8s juju_model=how-to juju_model_uuid=7b30903e-8941-4a40-864c-0cbbf277c57f loki.attribute.labels=container, job, filename, juju_application, juju_charm, juju_model, juju_model_uuid, juju_unit, snap_name, path
```
**Note**: the log body is enclosed in curly braces.

### Traces
A trace signal flowing through the pipeline will look similar to:
```shell
ResourceTraces #0 juju_application=graf juju_charm=grafana-k8s juju_model=how-to juju_model_uuid=7b30903e-8941-4a40-864c-0cbbf277c57f juju_unit=graf/1 process.runtime.description=go version go1.19.13 linux/amd64 service.name=grafana service.version=3.5.5 telemetry.sdk.language=go telemetry.sdk.name=opentelemetry telemetry.sdk.version=1.14.0
ScopeTraces #0 component-main
open session c13051073ab5a5b1a158008cc460eb5d 8519ed6a8feb05c0 transaction=true
     {"resource": {"service.instance.id": "3e0e472b-2c94-4a2e-836a-56d110d2cc66", "service.name": "otelcol", "service.version": "0.130.1"}, "otelcol.component.id": "debug", "otelcol.component.kind": "exporter", "otelcol.signal": "traces"}
2025-08-11T08:25:22.183Z     debug   sampling/status_code.go:54      Evaluating spans in status code filter      {"resource": {"service.instance.id": "3e0e472b-2c94-4a2e-836a-56d110d2cc66", "service.name": "otelcol", "service.version": "0.130.1"}, "otelcol.component.id": "tail_sampling", "otelcol.component.kind": "processor", "otelcol.pipeline.id": "traces", "otelcol.signal": "traces", "policy": "status_code"}
2025-08-11T08:25:22.183Z     debug   sampling/string_tag_filter.go:95        Evaluating spans in string-tag filter       {"resource": {"service.instance.id": "3e0e472b-2c94-4a2e-836a-56d110d2cc66", "service.name": "otelcol", "service.version": "0.130.1"}, "otelcol.component.id": "tail_sampling", "otelcol.component.kind": "processor", "otelcol.pipeline.id": "traces", "otelcol.signal": "traces", "policy": "string_attribute"}
2025-08-11T08:25:22.183Z     debug   sampling/probabilistic.go:46    Evaluating spans in probabilistic filter    {"resource": {"service.instance.id": "3e0e472b-2c94-4a2e-836a-56d110d2cc66", "service.name": "otelcol", "service.version": "0.130.1"}, "otelcol.component.id": "tail_sampling", "otelcol.component.kind": "processor", "otelcol.pipeline.id": "traces", "otelcol.signal": "traces", "policy": "probabilistic"}
```

## Understanding processors
The [filter](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/filterprocessor/README.md) processor supports the [OpenTelemetry Transformation Language (OTTL)](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/pkg/ottl/README.md). This allows us to  define:
1. A function that transforms (or drops) telemetry
2. Optionally, a condition that determines whether the function is executed.

Be aware of the **Warnings** section of a processor's README:
- [filterprocessor#warnings](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/filterprocessor#warnings)

Incorrectly modifying or dropping telemetry can result in data loss!

## Drop metrics
By default, otelcol self-scrapes its metrics and sends it into the configured pipeline, which is useful for operational diagnostics. In some use cases, this self-scraping telemetry is not desired and can be dropped.

###  Via metric name in scrape config
Charms that integrate with prometheus or otelcol, provide a "scrape config" to `MetricsEndpointProvider` (imported from [`charms.prometheus_k8s.v0.prometheus_scrape`](https://charmhub.io/prometheus-k8s/libraries/prometheus_scrape)).

Let's take for example the alertmanager self-metrics that prometheus scrapes. If we do not want prometheus or otelcol to ingest any `scrape_samples_*` metrics from alertmanager, then we need to adjust the scrape job specified in the alertmanager charm:

```diff
diff --git a/src/charm.py b/src/charm.py
index fa3678c..f0e943b 100755
--- a/src/charm.py
+++ b/src/charm.py
@@ -250,6 +250,13 @@ class AlertmanagerCharm(CharmBase):
             "scheme": metrics_endpoint.scheme,
             "metrics_path": metrics_path,
             "static_configs": [{"targets": [target]}],
+            "metric_relabel_configs": [
+                {
+                    "source_labels": ["__name__"],
+                    "regex": "scrape_samples_.+",
+                    "action": "drop",
+                }
+            ]
         }
 
         return [config]
```
### Via the scrape-config charm
In a typical scrape-config deployment such as:

```{mermaid}
graph LR
    some-external-target --- scrape-target --- scrape-config --- prometheus
```

We can specify the `drop` action via a config option for the scrape-config charm:

```shell
$ juju config sc metric_relabel_configs="$(cat <<EOF
- source_labels: ["__name__"]
  regex: "scrape_samples_.+"
  action: "drop"
EOF
)"
```

###  Via filter processor
```yaml
processors:
  filter/exclude:
      metrics:
        exclude:
          match_type: regexp
          metric_names:
            - "scrape_samples_.+"
```
Alternatively, you can use an OTTL expression for the entire `otelcol` service:
```yaml
processors:
  filter/exclude:
    metrics:
      datapoint:
          - 'resource.attributes["service.name"] == "otelcol"'
```

## Drop logs
The log bodies may contain successful (`2xx`) status codes. In some use cases, this telemetry is not desired and can be dropped using the filter processor.
```yaml
processors:
  filter/exclude:
    logs:
      exclude:
        match_type: regexp
        bodies:
          - '"status":2[0-9]{2}'
```

## Drop traces
When an application is scaled, we receive traces for multiple units. In some use cases, this telemetry is not desired and can be dropped using the filter processor.
```yaml
processors:
  filter/exclude:
    traces:
      span:
        - IsMatch(resource.attributes["juju_unit"], "graf/0")
```

## References
- The [OTLP data model](https://betterstack.com/community/guides/observability/otlp/#the-otlp-data-model)
- Official docs: [`<relabel_config>`](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config)
- [Dropping metrics at scrape time with Prometheus](https://www.robustperception.io/dropping-metrics-at-scrape-time-with-prometheus/) (robustperception, 2015)
- [How relabeling in Prometheus works](https://grafana.com/blog/2022/03/21/how-relabeling-in-prometheus-works/) (grafana.com, 2022)
- [How to drop and delete metrics in Prometheus](https://tanmay-bhat.github.io/posts/how-to-drop-and-delete-metrics-in-prometheus/) (gh:tanmay-bhat, 2022)
- Playgrounds:
  - https://demo.promlens.com/
  - https://relabeler.promlabs.com/
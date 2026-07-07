---
myst:
  html_meta:
    description: "SLI metrics for monitoring Grafana Tempo health using Sloth in the Canonical Observability Stack."
---

# Tempo SLIs

This page documents Service Level Indicators (SLIs) for monitoring the health of Tempo.
To set up Service Level Objectives (SLOs), see [Set up SLOs with Sloth](/how-to/integrate/set-up-slos-with-sloth).

These metrics are recommended as Service Level Indicators for Tempo. They apply the [RED method](https://grafana.com/blog/2018/08/02/the-red-method-how-to-instrument-your-services/) (Rate, Errors, Duration) to each component of the distributed tracing pipeline.

## Trace ingestion

The distributor receives spans from instrumented applications and forwards them to ingesters. These metrics measure the health of the write path.

| Metric | Type | Description |
|--------|------|-------------|
| `tempo_receiver_accepted_spans` | Counter | Spans successfully accepted by the distributor per receiver protocol |
| `tempo_receiver_refused_spans` | Counter | Spans refused by the distributor due to limits or errors |
| `tempo_distributor_spans_received_total` | Counter | Total spans received by the distributor after protocol decoding |
| `tempo_distributor_bytes_received_total` | Counter | Total bytes received by the distributor |
| `tempo_distributor_push_duration_seconds` | Histogram | End-to-end push latency through the distributor to the ingesters |
| `tempo_discarded_spans_total` | Counter | Spans discarded due to policy limits, labelled by `reason` (`trace_too_large`, `live_traces_exceeded`, `unknown_error`) |

The primary availability SLI for the write path is the ratio of accepted to total received spans:

```promql
sum(rate(tempo_receiver_accepted_spans[5m]))
/
(sum(rate(tempo_receiver_accepted_spans[5m])) + sum(rate(tempo_receiver_refused_spans[5m])))
```

## Trace retrieval

The query frontend and queriers serve trace search and retrieval requests. These metrics measure the health of the read path. They only produce data when queries are actively being made.

| Metric | Type | Description |
|--------|------|-------------|
| `tempo_request_duration_seconds` | Histogram | Request latency per route and `status_code`; read-path routes match `api_*` and `querier_api_*`; write-path routes are `/tempopb.Pusher/PushBytesV2` and `/tempopb.MetricsGenerator/PushSpans` |
| `tempo_query_frontend_queries_total` | Counter | Queries processed by the query frontend, labelled by `op` (traces, search, metadata, metrics) and `result` (`completed`, `cancelled`) |
| `tempo_query_frontend_queries_within_slo_total` | Counter | Queries that completed within Tempo's built-in latency SLO, labelled by `op`; useful for computing an SLO compliance ratio |
| `tempo_query_frontend_queue_duration_seconds` | Histogram | Time requests spend in the query frontend scheduler queue before dispatching to queriers |
| `tempo_query_frontend_bytes_inspected_total` | Counter | Bytes scanned per query operation; high values indicate expensive queries |

The read-path availability SLI uses the query frontend's built-in SLO tracking:

```promql
sum by (op) (rate(tempo_query_frontend_queries_within_slo_total[5m]))
/
sum by (op) (rate(tempo_query_frontend_queries_total{result="completed"}[5m]))
```

A latency SLI for the HTTP API (P99 across all user-facing routes):

```promql
histogram_quantile(0.99, sum by (le) (
  rate(tempo_request_duration_seconds_bucket{route=~"api_.*"}[5m])
))
```

## Ingester

The ingester holds recent traces in memory before flushing them to the backend store. Flush failures or an excessively large in-memory trace set are direct threats to data durability.

| Metric | Type | Description |
|--------|------|-------------|
| `tempo_ingester_live_traces` | Gauge | Number of traces currently held in ingester memory |
| `tempo_ingester_traces_created_total` | Counter | Total traces created by the ingester |
| `tempo_ingester_blocks_flushed_total` | Counter | Total blocks successfully flushed to backend storage |
| `tempo_ingester_failed_flushes_total` | Counter | Flush attempts that failed; should remain at 0 |
| `tempo_ingester_flush_duration_seconds` | Histogram | Duration of flush operations from memory to backend |
| `tempo_ingester_flush_queue_length` | Gauge | Number of traces queued for flushing; high values indicate backend pressure |

## Backend storage

Tempo persists trace data as blocks in object storage. These metrics measure the health and performance of the storage layer.

| Metric | Type | Description |
|--------|------|-------------|
| `tempodb_backend_request_duration_seconds` | Histogram | Object storage request latency, labelled by `operation` (GET, PUT, POST, DELETE) and `status_code` |
| `tempodb_backend_bytes_total` | Counter | Cumulative bytes transferred to and from backend storage |
| `tempodb_backend_objects_total` | Gauge | Total objects present in backend storage |
| `tempodb_blocklist_length` | Gauge | Number of blocks known to Tempo per tenant; directly influences per-query overhead |
| `tempodb_blocklist_poll_duration_seconds` | Histogram | Time taken to refresh the block list from backend storage |
| `tempodb_blocklist_poll_errors_total` | Counter | Errors refreshing the block list; should remain at 0 |
| `tempodb_blocklist_tenant_index_age_seconds` | Gauge | Age of the cached tenant block index; values above 600 seconds indicate a stale index and degraded query performance |

## Compaction

The compactor merges small blocks into larger ones and enforces retention. Backlog accumulation and errors here indicate storage management problems that will eventually affect query performance.

| Metric | Type | Description |
|--------|------|-------------|
| `tempodb_compaction_outstanding_blocks` | Gauge | Blocks awaiting compaction; sustained values above 100 per worker indicate a compaction backlog |
| `tempodb_compaction_errors_total` | Counter | Errors encountered during compaction; any non-zero rate warrants investigation |
| `tempodb_retention_deleted_total` | Counter | Blocks deleted by the retention policy |
| `tempodb_retention_errors_total` | Counter | Errors encountered during retention processing; should remain at 0 |
| `tempodb_retention_duration_seconds` | Histogram | Duration of each retention processing cycle |

## Cluster membership

Tempo uses a distributed ring for component coordination. These metrics measure the health of cluster membership. An `Unhealthy` ring member count above 0 means at least one component has stopped sending heartbeats.

| Metric | Type | Description |
|--------|------|-------------|
| `tempo_ring_members` | Gauge | Ring members by `name` (compactor, ingester, metrics-generator) and `state` (ACTIVE, JOINING, LEAVING, PENDING, Unhealthy) |
| `tempo_memberlist_client_cluster_members_count` | Gauge | Total members visible in the memberlist gossip cluster |
| `tempo_memberlist_client_cluster_node_health_score` | Gauge | Memberlist health score per node; 0 is fully healthy, higher values indicate packet loss or degraded connectivity |

A ring availability SLI per component:

```promql
sum by (name) (tempo_ring_members{state="Unhealthy"})
```

This should equal 0 for all component names under normal operating conditions.

## Metrics generator

The metrics generator is an optional component that derives Prometheus metrics from incoming traces (span metrics and service graphs). These metrics measure the health of that processing pipeline.

| Metric | Type | Description |
|--------|------|-------------|
| `tempo_metrics_generator_spans_received_total` | Counter | Spans forwarded from the distributor to the metrics generator |
| `tempo_metrics_generator_spans_discarded_total` | Counter | Spans discarded by the metrics generator, labelled by `reason` |
| `tempo_metrics_generator_registry_active_series` | Gauge | Active Prometheus series maintained by the generator; used to track cardinality |
| `tempo_metrics_generator_registry_max_active_series` | Gauge | Per-tenant series limit for the generator; `0` means unlimited |

A span processing health SLI:

```promql
1 - (
  sum(rate(tempo_metrics_generator_spans_discarded_total[5m]))
  /
  sum(rate(tempo_metrics_generator_spans_received_total[5m]))
)
```

## Span data quality

These metrics capture timing properties of arriving spans and can reveal instrumentation problems in upstream services. Late-arriving spans may be outside the active search window and become permanently unsearchable.

| Metric | Type | Description |
|--------|------|-------------|
| `tempo_spans_distance_in_past_seconds` | Histogram | How many seconds in the past span timestamps are at the time of arrival; P99 values consistently above the search lookback window indicate spans that will not be findable |
| `tempo_spans_distance_in_future_seconds` | Histogram | How many seconds in the future span timestamps are; any non-zero observations indicate clock-skew or misconfigured instrumentation in the sending service |

---
myst:
  html_meta:
    description: "SLI metrics for monitoring Loki health using Sloth in the Canonical Observability Stack."
---

# Loki SLIs

This page documents Service Level Indicators (SLIs) for monitoring the health of Loki.
To set up Service Level Objectives (SLOs), see [Set up SLOs with Sloth](/how-to/integrate/set-up-slos-with-sloth).

These metrics are recommended as Service Level Indicators for Loki. They cover the write path (log ingestion), read path (query serving), and supporting subsystems.

## Log ingestion (write path)

The distributor receives log streams from Promtail or other clients, and the ingester persists them to object storage. These metrics measure the health of the write path.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_distributor_lines_received_total` | Counter | Total log lines received by the distributor |
| `loki_distributor_bytes_received_total` | Counter | Total bytes received by the distributor |
| `loki_distributor_ingester_appends_total` | Counter | Total successful append calls to ingesters |
| `loki_discarded_samples_total` | Counter | Samples discarded by `reason` (rate_limited, out_of_order, ingestion_rate, etc.) |
| `loki_discarded_bytes_total` | Counter | Bytes discarded by `reason` |

An availability SLI for the write path is the ratio of successful ingester appends:

```promql
sum(rate(loki_distributor_ingester_appends_total[5m]))
```

A discard rate SLI shows the proportion of data being rejected:

```promql
sum by (reason) (rate(loki_discarded_samples_total[5m]))
```

## Ingester

The ingester holds recent log streams in memory, builds chunks, and flushes them to the backend store. These metrics capture ingester health and resource pressure.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_ingester_memory_streams` | Gauge | Number of active streams held in ingester memory |
| `loki_ingester_memory_chunks` | Gauge | Number of chunks in ingester memory |
| `loki_ingester_chunks_flushed_total` | Counter | Total chunks flushed to backend storage |
| `loki_ingester_chunks_flush_failures_total` | Counter | Chunk flush failures; should remain at 0 |
| `loki_ingester_flush_queue_length` | Gauge | Number of chunks queued for flushing; high values indicate backend pressure |

A flush failure SLI:

```promql
sum(rate(loki_ingester_chunks_flush_failures_total[5m]))
/
sum(rate(loki_ingester_chunks_flushed_total[5m]))
```

## Write-ahead log (WAL)

The WAL provides durability for unflushed data in the ingester.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_ingester_wal_disk_full_failures_total` | Counter | Failures due to WAL disk being full |
| `loki_ingester_wal_replay_active` | Gauge | Whether WAL replay is currently active (1) or not (0) |

## Query performance (read path)

Loki serves log queries through the query frontend, queriers, and query scheduler. These metrics measure read-path health.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_request_duration_seconds` | Histogram | HTTP/gRPC request latency by route, method, and status code |
| `loki_inflight_requests` | Gauge | Number of inflight requests across all routes |
| `loki_query_frontend_queries_in_progress` | Gauge | Number of queries currently being processed |
| `loki_query_frontend_retries` | Histogram | Number of retries per query |
| `loki_query_scheduler_queue_duration_seconds` | Histogram | Time queries spend in the scheduler queue before being picked up |
| `loki_querier_worker_inflight_queries` | Gauge | Inflight queries per worker |

A latency SLI for the read API (P99):

```promql
histogram_quantile(0.99, sum by (le) (
  rate(loki_request_duration_seconds_bucket{method="gRPC",route!~".*Pusher.*"}[5m])
))
```

## TSDB index

Loki uses TSDB-based index storage. These metrics capture index build and maintenance health.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_tsdb_build_index_attempts_total` | Counter | TSDB index build attempts by `status` (success, failure) |
| `loki_tsdb_build_index_last_successful_timestamp_seconds` | Gauge | Timestamp of the last successful index build |
| `loki_tsdb_head_rotation_attempts_total` | Counter | TSDB head rotation attempts by `status` |
| `loki_tsdb_wal_truncation_attempts_total` | Counter | WAL truncation attempts by `status` |

An index build success SLI:

```promql
sum by (component) (rate(loki_tsdb_build_index_attempts_total{status="success"}[5m]))
/
sum by (component) (rate(loki_tsdb_build_index_attempts_total[5m]))
```

## Cache

Loki uses caching to accelerate queries and reduce storage load. Cache efficiency directly impacts read-path latency.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_cache_hits` | Counter | Total cache hits |
| `loki_cache_fetched_keys` | Counter | Total cache keys fetched |
| `loki_cache_corrupt_chunks_total` | Counter | Corrupt chunks detected in cache |

A cache hit ratio SLI:

```promql
sum(rate(loki_cache_hits[5m]))
/
sum(rate(loki_cache_fetched_keys[5m]))
```

## Ruler (alerting)

Loki's ruler evaluates recording and alerting rules against LogQL expressions.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_ruler_config_last_reload_successful` | Gauge | Whether the last ruler config reload succeeded (1 = success, 0 = failure) |
| `loki_prometheus_notifications_errors_total` | Counter | Alert notification errors |
| `loki_prometheus_notifications_dropped_total` | Counter | Alert notifications dropped |

## Ring / cluster membership

Loki uses a distributed hash ring for component discovery and ownership.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_ring_members` | Gauge | Ring members by `name` (ingester, distributor, compactor, scheduler) and `state` (ACTIVE, JOINING, LEAVING, PENDING, Unhealthy) |

A ring health SLI (unhealthy members should be 0):

```promql
sum by (name) (loki_ring_members{state="Unhealthy"})
```

## Compactor

The compactor merges TSDB index files and applies retention.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_compactor_apply_retention_operation_duration_seconds` | Gauge | Duration of retention application |
| `loki_compactor_apply_retention_last_successful_run_timestamp_seconds` | Gauge | Timestamp of the last successful retention run |
| `loki_boltdb_shipper_compact_tables_operation_total` | Counter | Table compaction operations by `status` |
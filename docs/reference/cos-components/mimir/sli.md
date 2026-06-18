---
myst:
  html_meta:
    description: "SLI metrics for monitoring Mimir health using Sloth in the Canonical Observability Stack."
---

# Mimir SLIs

This page documents Service Level Indicators (SLIs) for monitoring the health of Mimir.
To set up Service Level Objectives (SLOs), see [Set up SLOs with Sloth](/how-to/integrate/set-up-slos-with-sloth).

These metrics are recommended as Service Level Indicators for Mimir. They cover the write path (metric ingestion), read path (query serving), storage, and supporting subsystems.

## Write path (distributor)

The distributor receives samples from Prometheus and replicates them to ingesters. These metrics measure the health of the ingestion pipeline.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_distributor_received_samples_total` | Counter | Total samples received from clients |
| `cortex_distributor_inflight_push_requests` | Gauge | Number of inflight push requests |
| `cortex_distributor_ingestion_rate_samples_per_second` | Gauge | Current ingestion rate in samples per second |
| `cortex_distributor_instance_rejected_requests_total` | Counter | Requests rejected due to instance limits |
| `cortex_distributor_samples_per_request` | Histogram | Samples per push request |

An availability SLI for the write path — the ratio of successful requests to total requests:

```promql
1 -
(
  sum(rate(cortex_distributor_instance_rejected_requests_total[5m]))
  /
  sum(rate(cortex_distributor_received_requests_total[5m]))
)
```

## Ingester

The ingester receives replicated samples, stores them in TSDB blocks, and ships them to long-term object storage.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_ingester_memory_series` | Gauge | Number of in-memory series per tenant |
| `cortex_ingester_active_series` | Gauge | Number of active series per tenant |
| `cortex_ingester_ingested_samples_total` | Counter | Total samples ingested |
| `cortex_ingester_ingested_samples_failures_total` | Counter | Samples that failed ingestion |
| `cortex_ingester_instance_rejected_requests_total` | Counter | Requests rejected due to instance limits |

### TSDB

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_ingester_tsdb_head_chunks` | Gauge | Number of chunks in the TSDB head |
| `cortex_ingester_tsdb_compactions_failed_total` | Counter | Failed TSDB block compactions |
| `cortex_ingester_tsdb_wal_corruptions_total` | Counter | WAL corruption events |

### Shipper

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_ingester_shipper_uploads_total` | Counter | Total block uploads to object storage |
| `cortex_ingester_shipper_upload_failures_total` | Counter | Block upload failures |
| `cortex_ingester_oldest_unshipped_block_timestamp_seconds` | Gauge | Timestamp of the oldest block not yet shipped |

## Query frontend

The query frontend handles query decomposition, queuing, and caching. These metrics measure read-path performance.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_query_frontend_queue_duration_seconds` | Histogram | Time queries spend in the queue before dispatch |
| `cortex_query_frontend_retries` | Histogram | Number of retries per query |
| `cortex_frontend_query_result_cache_hits_total` | Counter | Query result cache hits |
| `cortex_frontend_query_result_cache_requests_total` | Counter | Query result cache requests |

A query result cache hit ratio SLI:

```promql
sum(rate(cortex_frontend_query_result_cache_hits_total[5m]))
/
sum(rate(cortex_frontend_query_result_cache_requests_total[5m]))
```

## Querier

Queriers execute PromQL queries against ingesters and store gateways.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_querier_blocks_queried_total` | Counter | Total blocks queried from store gateways |
| `cortex_querier_blocks_consistency_checks_total` | Counter | Block consistency checks performed |
| `cortex_querier_blocks_consistency_checks_failed_total` | Counter | Block consistency checks that failed |

## Store gateway

Store gateways serve long-term data from object storage.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_bucket_store_block_load_failures_total` | Counter | Block loading failures |
| `cortex_bucket_store_blocks_loaded` | Gauge | Number of blocks currently loaded |
| `cortex_bucket_store_series_hash_cache_hits_total` | Counter | Series hash cache hits |
| `cortex_bucket_store_series_hash_cache_requests_total` | Counter | Series hash cache requests |

## HTTP API / gRPC

These metrics cover general request health across all Mimir components.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_request_duration_seconds` | Histogram | Request latency by route, method, and status code |
| `cortex_inflight_requests` | Gauge | Number of inflight requests across all routes |

An error rate SLI (ratio of 5xx responses to all requests):

```promql
sum by (route) (rate(cortex_request_duration_seconds_count{status_code=~"5.."}[5m]))
/
sum by (route) (rate(cortex_request_duration_seconds_count[5m]))
```

## Compactor

The compactor merges smaller TSDB blocks into larger ones and applies retention.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_compactor_runs_started_total` | Counter | Compaction runs started |
| `cortex_compactor_runs_completed_total` | Counter | Compaction runs completed |
| `cortex_compactor_runs_failed_total` | Counter | Compaction runs that failed |
| `cortex_compactor_last_successful_run_timestamp_seconds` | Gauge | Timestamp of the last successful compaction run |

## Ruler

The ruler evaluates PromQL recording and alerting rules.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_prometheus_rule_evaluations_total` | Counter | Total rule evaluations |
| `cortex_prometheus_rule_evaluation_failures_total` | Counter | Failed rule evaluations |
| `cortex_prometheus_rule_evaluation_duration_seconds` | Summary | Rule evaluation duration |
| `cortex_prometheus_notifications_dropped_total` | Counter | Alert notifications dropped |

## Ring / cluster membership

Mimir uses a distributed hash ring for component discovery. Unhealthy members indicate cluster connectivity problems.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_ring_members` | Gauge | Ring members by name and state |
| `cortex_ring_tokens_total` | Gauge | Tokens in the ring per component |

A ring health SLI (unhealthy members should be 0):

```promql
sum by (name) (cortex_ring_members{state="Unhealthy"})
```

## KV store

The KV store (typically Consul or etcd) is used for ring state coordination.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_kv_request_duration_seconds` | Histogram | KV store request latency by operation and status code |

## Query engine

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_mimir_query_engine_supported_queries_total` | Counter | Total queries evaluated by the query engine |
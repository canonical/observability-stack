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

The distributor receives samples from Prometheus via remote write and replicates them to ingesters. These metrics measure the health of the ingestion pipeline.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_distributor_received_samples_total` | Counter | Total samples received from clients |
| `cortex_distributor_received_exemplars_total` | Counter | Total exemplars received from clients |
| `cortex_distributor_received_metadata_total` | Counter | Total metadata entries received from clients |
| `cortex_distributor_received_native_histogram_samples_total` | Counter | Total native histogram samples received |
| `cortex_distributor_received_native_histogram_buckets_total` | Counter | Total native histogram buckets received |
| `cortex_distributor_received_requests_total` | Counter | Total push requests received |
| `cortex_distributor_inflight_push_requests` | Gauge | Number of inflight push requests |
| `cortex_distributor_inflight_push_requests_bytes` | Gauge | Total bytes of inflight push requests |
| `cortex_distributor_ingester_clients` | Gauge | Number of connected ingester clients |
| `cortex_distributor_replication_factor` | Gauge | Configured replication factor |
| `cortex_distributor_ingestion_rate_samples_per_second` | Gauge | Current ingestion rate in samples per second |
| `cortex_distributor_instance_rejected_requests_total` | Counter | Requests rejected due to instance limits |
| `cortex_distributor_samples_in_total` | Counter | Total samples tracked as input (after ingestion, before replication) |
| `cortex_distributor_samples_per_request` | Histogram | Samples per push request |
| `cortex_distributor_exemplars_per_request` | Histogram | Exemplars per push request |

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

The ingester receives replicated samples, stores them in TSDB blocks, and ships them to long-term object storage. These metrics capture ingester health and capacity.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_ingester_memory_series` | Gauge | Number of in-memory series per tenant |
| `cortex_ingester_memory_series_created_total` | Counter | Total series created |
| `cortex_ingester_memory_series_removed_total` | Counter | Total series removed |
| `cortex_ingester_active_series` | Gauge | Number of active series per tenant |
| `cortex_ingester_memory_users` | Gauge | Number of tenants with data in ingester memory |
| `cortex_ingester_memory_metadata` | Gauge | Number of metadata entries in memory |
| `cortex_ingester_ingested_samples_total` | Counter | Total samples ingested |
| `cortex_ingester_ingested_samples_failures_total` | Counter | Samples that failed ingestion |
| `cortex_ingester_inflight_push_requests` | Gauge | Inflight push requests |
| `cortex_ingester_inflight_push_requests_bytes` | Gauge | Inflight push request bytes |
| `cortex_ingester_ingestion_rate_samples_per_second` | Gauge | Current ingestion rate in samples per second |
| `cortex_ingester_instance_limits` | Gauge | Per-instance limits (max_series, max_tenants, max_ingestion_rate) |
| `cortex_ingester_instance_rejected_requests_total` | Counter | Requests rejected due to instance limits |

An ingester ingestion failure SLI:

```promql
sum(rate(cortex_ingester_ingested_samples_failures_total[5m]))
/
sum(rate(cortex_ingester_ingested_samples_total[5m]))
```

Series utilization relative to limits:

```promql
cortex_ingester_memory_series
/
ignoring(limit) cortex_ingester_instance_limits{limit="max_series"}
```

### TSDB

Mimir ingesters run an embedded Prometheus TSDB per tenant. These metrics measure TSDB health.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_ingester_tsdb_head_series_not_found_total` | Counter | Series not found in TSDB head lookups |
| `cortex_ingester_tsdb_head_chunks` | Gauge | Number of chunks in the TSDB head |
| `cortex_ingester_tsdb_head_chunks_created_total` | Counter | Chunks created in TSDB head |
| `cortex_ingester_tsdb_head_chunks_removed_total` | Counter | Chunks removed from TSDB head |
| `cortex_ingester_tsdb_head_gc_duration_seconds` | Summary | Duration of TSDB head garbage collection |
| `cortex_ingester_tsdb_head_truncations_total` | Counter | TSDB head truncations |
| `cortex_ingester_tsdb_head_truncations_failed_total` | Counter | Failed TSDB head truncations |
| `cortex_ingester_tsdb_compactions_total` | Counter | TSDB block compactions |
| `cortex_ingester_tsdb_compactions_failed_total` | Counter | Failed TSDB block compactions |
| `cortex_ingester_tsdb_compaction_duration_seconds` | Histogram | Duration of TSDB block compactions |
| `cortex_ingester_tsdb_reloads_total` | Counter | TSDB reloads |
| `cortex_ingester_tsdb_reloads_failures_total` | Counter | Failed TSDB reloads |
| `cortex_ingester_tsdb_storage_blocks_bytes` | Gauge | Disk space used by TSDB blocks |
| `cortex_ingester_tsdb_wal_corruptions_total` | Counter | WAL corruption events |
| `cortex_ingester_tsdb_wal_truncations_total` | Counter | WAL truncations |
| `cortex_ingester_tsdb_wal_truncations_failed_total` | Counter | Failed WAL truncations |
| `cortex_ingester_tsdb_wal_writes_failed_total` | Counter | Failed WAL writes |
| `cortex_ingester_tsdb_out_of_order_samples_appended_total` | Counter | Out-of-order samples appended |
| `cortex_ingester_tsdb_mmap_chunk_corruptions_total` | Counter | Memory-mapped chunk corruptions |

### Shipper

The ingester ships completed TSDB blocks to object storage for long-term persistence.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_ingester_shipper_uploads_total` | Counter | Total block uploads to object storage |
| `cortex_ingester_shipper_upload_failures_total` | Counter | Block upload failures |
| `cortex_ingester_shipper_last_successful_upload_timestamp_seconds` | Gauge | Timestamp of the last successful block upload |
| `cortex_ingester_oldest_unshipped_block_timestamp_seconds` | Gauge | Timestamp of the oldest block not yet shipped; high values indicate shipping backlog |

A block shipping SLI:

```promql
sum(rate(cortex_ingester_shipper_upload_failures_total[5m]))
/
sum(rate(cortex_ingester_shipper_uploads_total[5m]))
```

## Query frontend

The query frontend handles query decomposition (splitting, sharding), queuing, and caching. These metrics measure read-path performance.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_query_frontend_queue_duration_seconds` | Histogram | Time queries spend in the frontend queue before dispatch |
| `cortex_query_frontend_enqueue_duration_seconds` | Histogram | Time to enqueue queries |
| `cortex_query_frontend_retries` | Histogram | Number of retries per query |
| `cortex_query_frontend_connected_clients` | Gauge | Connected querier clients |
| `cortex_query_frontend_querier_inflight_requests` | Gauge | Inflight requests per querier |
| `cortex_frontend_split_queries_total` | Counter | Total split queries |
| `cortex_frontend_instant_query_split_queries_total` | Counter | Split instant queries |
| `cortex_frontend_spun_off_subqueries_total` | Counter | Total sub-queries spun off |
| `cortex_frontend_query_result_cache_hits_total` | Counter | Query result cache hits |
| `cortex_frontend_query_result_cache_attempted_total` | Counter | Query result cache lookups attempted |
| `cortex_frontend_query_result_cache_requests_total` | Counter | Query result cache requests |
| `cortex_frontend_query_result_cache_skipped_total` | Counter | Query result cache lookups skipped |

A query result cache hit ratio SLI:

```promql
sum(rate(cortex_frontend_query_result_cache_hits_total[5m]))
/
sum(rate(cortex_frontend_query_result_cache_requests_total[5m]))
```

## Querier

Queriers execute PromQL queries against ingesters and store gateways. These metrics capture query execution health.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_querier_blocks_queried_total` | Counter | Total blocks queried from store gateways |
| `cortex_querier_blocks_found_total` | Counter | Total blocks found matching queries |
| `cortex_querier_blocks_consistency_checks_total` | Counter | Block consistency checks performed |
| `cortex_querier_blocks_consistency_checks_failed_total` | Counter | Block consistency checks that failed |
| `cortex_querier_queries_rejected_total` | Counter | Queries rejected due to limits |
| `cortex_querier_storegateway_instances_hit_per_query` | Histogram | Store gateway instances contacted per query |
| `cortex_querier_storegateway_refetches_per_query` | Histogram | Number of refetches from store gateways per query |

A block consistency SLI:

```promql
sum(rate(cortex_querier_blocks_consistency_checks_failed_total[5m]))
/
sum(rate(cortex_querier_blocks_consistency_checks_total[5m]))
```

## Store gateway

Store gateways serve long-term data from object storage. These metrics measure storage read-path health.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_bucket_stores_tenants_discovered` | Gauge | Tenants discovered in the bucket |
| `cortex_bucket_stores_tenants_synced` | Gauge | Tenants with synchronised bucket index |
| `cortex_bucket_stores_blocks_sync_seconds` | Histogram | Duration of block sync operations |
| `cortex_bucket_stores_blocks_last_successful_sync_timestamp_seconds` | Gauge | Timestamp of the last successful block sync |
| `cortex_bucket_stores_gate_queries_concurrent_max` | Gauge | Maximum concurrent queries allowed |
| `cortex_bucket_stores_gate_queries_in_flight` | Gauge | Queries currently in flight |
| `cortex_bucket_store_block_loads_total` | Counter | Block loading operations |
| `cortex_bucket_store_block_load_failures_total` | Counter | Block loading failures |
| `cortex_bucket_store_block_drops_total` | Counter | Block dropping operations |
| `cortex_bucket_store_block_drop_failures_total` | Counter | Block dropping failures |
| `cortex_bucket_store_blocks_loaded` | Gauge | Number of blocks currently loaded |
| `cortex_bucket_store_series_hash_cache_hits_total` | Counter | Series hash cache hits |
| `cortex_bucket_store_series_hash_cache_requests_total` | Counter | Series hash cache requests |
| `cortex_bucket_store_series_result_series_count` | Gauge | Result series count in bucket store queries |
| `cortex_bucket_store_series_batch_preloading_wait_duration_seconds` | Histogram | Wait time for series batch preloading |
| `cortex_bucket_store_series_batch_preloading_load_duration_seconds` | Histogram | Load time for series batch preloading |

A series hash cache hit ratio SLI:

```promql
sum(rate(cortex_bucket_store_series_hash_cache_hits_total[5m]))
/
sum(rate(cortex_bucket_store_series_hash_cache_requests_total[5m]))
```

## HTTP API / gRPC

These metrics cover general request health across all Mimir components.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_request_duration_seconds` | Histogram | Request latency by route, method, and status code |
| `cortex_request_message_bytes` | Histogram | Request message size in bytes |
| `cortex_response_message_bytes` | Histogram | Response message size in bytes |
| `cortex_inflight_requests` | Gauge | Number of inflight requests across all routes |

A latency SLI for all API routes (P99):

```promql
histogram_quantile(0.99, sum by (route, le) (
  rate(cortex_request_duration_seconds_bucket[5m])
))
```

An error rate SLI (ratio of 5xx responses to all requests):

```promql
sum by (route) (rate(cortex_request_duration_seconds_count{status_code=~"5.."}[5m]))
/
sum by (route) (rate(cortex_request_duration_seconds_count[5m]))
```

## Compactor

The compactor merges smaller TSDB blocks into larger ones, applies retention, and garbage-collects deleted blocks. Backlog indicates storage management issues.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_compactor_runs_started_total` | Counter | Compaction runs started |
| `cortex_compactor_runs_completed_total` | Counter | Compaction runs completed |
| `cortex_compactor_runs_failed_total` | Counter | Compaction runs that failed |
| `cortex_compactor_tenants_discovered` | Gauge | Tenants discovered for compaction |
| `cortex_compactor_tenants_processing_succeeded` | Counter | Tenants successfully compacted |
| `cortex_compactor_tenants_processing_failed` | Counter | Tenants that failed compaction |
| `cortex_compactor_tenants_skipped` | Counter | Tenants skipped during compaction |
| `cortex_compactor_last_successful_run_timestamp_seconds` | Gauge | Timestamp of the last successful compaction run |
| `cortex_compactor_compaction_interval_seconds` | Gauge | Configured compaction interval |
| `cortex_compactor_block_cleanup_started_total` | Counter | Block cleanup operations started |
| `cortex_compactor_block_cleanup_completed_total` | Counter | Block cleanup operations completed |
| `cortex_compactor_block_cleanup_failed_total` | Counter | Block cleanup operations that failed |
| `cortex_compactor_blocks_cleaned_total` | Counter | Total blocks cleaned up |
| `cortex_compactor_blocks_marked_for_deletion_total` | Counter | Blocks marked for deletion |
| `cortex_compactor_garbage_collection_total` | Counter | Garbage collection runs |
| `cortex_compactor_garbage_collection_failures_total` | Counter | Garbage collection failures |
| `cortex_compactor_garbage_collection_duration_seconds` | Histogram | Duration of garbage collection |

A compaction success SLI:

```promql
sum(rate(cortex_compactor_runs_completed_total[5m]))
/
sum(rate(cortex_compactor_runs_started_total[5m]))
```

## Ruler (alerting and recording rules)

The ruler evaluates PromQL recording and alerting rules. Latency and failures directly impact alert coverage and pre-computed metrics.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_ruler_managers_total` | Gauge | Number of registered rule managers |
| `cortex_ruler_sync_rules_total` | Counter | Rule sync cycles |
| `cortex_ruler_config_last_reload_successful` | Gauge | Whether the last config reload succeeded |
| `cortex_ruler_config_updates_total` | Counter | Rule config updates triggered by users |
| `cortex_ruler_ring_check_errors_total` | Counter | Errors during ring ownership checks |
| `cortex_ruler_clients` | Gauge | Connected ruler clients |
| `cortex_prometheus_rule_evaluation_duration_seconds` | Summary | Rule evaluation duration |
| `cortex_prometheus_rule_evaluation_failures_total` | Counter | Failed rule evaluations |
| `cortex_prometheus_rule_evaluations_total` | Counter | Total rule evaluations |
| `cortex_prometheus_rule_group_duration_seconds` | Summary | Rule group evaluation duration |
| `cortex_prometheus_rule_group_iterations_total` | Counter | Scheduled rule group evaluations |
| `cortex_prometheus_rule_group_iterations_missed_total` | Counter | Missed rule group evaluations |
| `cortex_prometheus_rule_group_rules` | Gauge | Number of rules per rule group |
| `cortex_prometheus_notifications_sent_total` | Counter | Alert notifications sent |
| `cortex_prometheus_notifications_dropped_total` | Counter | Alert notifications dropped |
| `cortex_prometheus_notifications_queue_length` | Gauge | Current notification queue depth |
| `cortex_prometheus_notifications_queue_capacity` | Gauge | Notification queue capacity |

A rule evaluation failure SLI:

```promql
sum(rate(cortex_prometheus_rule_evaluation_failures_total[5m]))
/
sum(rate(cortex_prometheus_rule_evaluations_total[5m]))
```

## Ring / cluster membership

Mimir uses a distributed hash ring for consistent hashing and component discovery. Unhealthy members indicate cluster connectivity problems.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_ring_members` | Gauge | Ring members by `name` (ingester, distributor, compactor, etc.) and `state` (ACTIVE, JOINING, LEAVING, PENDING, Unhealthy) |
| `cortex_ring_tokens_total` | Gauge | Tokens in the ring per component |
| `cortex_ring_member_heartbeats_total` | Counter | Heartbeats sent by ring members |
| `cortex_ring_member_tokens_owned` | Gauge | Tokens owned by each member |
| `cortex_ring_member_tokens_to_own` | Gauge | Target tokens to own |
| `cortex_ring_oldest_member_timestamp` | Gauge | Timestamp of the oldest ring member |

A ring health SLI (unhealthy members should be 0):

```promql
sum by (name) (cortex_ring_members{state="Unhealthy"})
```

## KV store

The KV store (typically Consul or etcd) is used for ring state and HA tracker coordination.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_kv_request_duration_seconds` | Histogram | KV store request latency by operation and status code |

## Query engine

Mimir's query engine includes optimisations such as common subexpression elimination. These metrics capture query engine planning overhead.

| Metric | Type | Description |
|--------|------|-------------|
| `cortex_mimir_query_engine_plan_stage_latency_seconds` | Histogram | Query plan stage latency |
| `cortex_mimir_query_engine_estimated_query_peak_memory_consumption` | Histogram | Estimated peak memory per query |
| `cortex_mimir_query_engine_supported_queries_total` | Counter | Total queries evaluated by the query engine |
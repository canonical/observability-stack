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
| `loki_distributor_inflight_bytes` | Gauge | Inflight bytes currently being processed by the distributor |
| `loki_distributor_ingester_appends_total` | Counter | Total successful append calls to ingesters |
| `loki_distributor_ingester_clients` | Gauge | Number of ingester clients the distributor is connected to |
| `loki_distributor_replication_factor` | Gauge | Configured replication factor |
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
| `loki_ingester_streams_created_total` | Counter | Total streams created |
| `loki_ingester_streams_removed_total` | Counter | Total streams removed |
| `loki_ingester_chunks_created_total` | Counter | Total chunks created |
| `loki_ingester_chunks_flushed_total` | Counter | Total chunks flushed to backend storage |
| `loki_ingester_chunks_flush_failures_total` | Counter | Chunk flush failures; should remain at 0 |
| `loki_ingester_chunks_stored_total` | Counter | Total chunks successfully stored |
| `loki_ingester_chunk_size_bytes` | Histogram | Flushed chunk size distribution |
| `loki_ingester_chunk_age_seconds` | Histogram | Age of chunks at flush time |
| `loki_ingester_chunk_encode_time_seconds` | Histogram | Time spent encoding chunks during flush |
| `loki_ingester_flush_queue_length` | Gauge | Number of chunks queued for flushing; high values indicate backend pressure |
| `loki_ingester_limiter_enabled` | Gauge | Whether the ingester rate limiter is enabled |
| `loki_ingester_samples_per_chunk` | Histogram | Number of samples per chunk |

A flush failure SLI:

```promql
sum(rate(loki_ingester_chunks_flush_failures_total[5m]))
/
sum(rate(loki_ingester_chunks_flushed_total[5m]))
```

## Write-ahead log (WAL)

The WAL provides durability for unflushed data in the ingester. These metrics capture WAL health and capacity pressure.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_ingester_wal_bytes_in_use` | Gauge | Current WAL disk usage in bytes |
| `loki_ingester_wal_disk_usage_percent` | Gauge | WAL disk usage as a percentage |
| `loki_ingester_wal_disk_full_failures_total` | Counter | Failures due to WAL disk being full |
| `loki_ingester_wal_records_logged_total` | Counter | Total WAL records written |
| `loki_ingester_wal_logged_bytes_total` | Counter | Total bytes written to WAL |
| `loki_ingester_wal_discarded_samples_total` | Counter | Samples discarded from WAL |
| `loki_ingester_wal_discarded_bytes_total` | Counter | Bytes discarded from WAL |
| `loki_ingester_wal_replay_active` | Gauge | Whether WAL replay is currently active (1) or not (0) |
| `loki_ingester_wal_replay_duration_seconds` | Gauge | Duration of the last WAL replay |
| `loki_ingester_wal_recovered_streams_total` | Counter | Streams recovered from WAL during replay |
| `loki_ingester_wal_recovered_entries_total` | Counter | Log entries recovered from WAL during replay |
| `loki_ingester_wal_recovered_bytes_total` | Counter | Bytes recovered from WAL during replay |

## Query performance (read path)

Loki serves log queries through the query frontend, queriers, and query scheduler. These metrics measure read-path health.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_request_duration_seconds` | Histogram | HTTP/gRPC request latency by route, method, and status code |
| `loki_request_message_bytes` | Histogram | Request message size in bytes |
| `loki_response_message_bytes` | Histogram | Response message size in bytes |
| `loki_inflight_requests` | Gauge | Number of inflight requests across all routes |

A latency SLI for the read API (P99):

```promql
histogram_quantile(0.99, sum by (le) (
  rate(loki_request_duration_seconds_bucket{method="gRPC",route!~".*Pusher.*"}[5m])
))
```

## Query frontend

The query frontend splits, shards, and parallelises queries. These metrics capture frontend efficiency and query workload.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_query_frontend_queries_in_progress` | Gauge | Number of queries currently being processed |
| `loki_query_frontend_connected_schedulers` | Gauge | Number of connected query schedulers |
| `loki_query_frontend_partitions` | Histogram | Number of partitions (query shards) per query |
| `loki_query_frontend_shard_factor` | Histogram | Shard factor applied to queries |
| `loki_query_frontend_retries` | Histogram | Number of retries per query |
| `loki_query_frontend_query_label_filters` | Histogram | Number of label filters per query |
| `loki_query_frontend_log_result_cache_hit_total` | Counter | Log result cache hits |
| `loki_query_frontend_log_result_cache_miss_total` | Counter | Log result cache misses |

## Query scheduler

The query scheduler manages the queue of pending queries for queriers. Queue depth and latency indicate whether queriers can keep up with demand.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_query_scheduler_inflight_requests` | Gauge | Inflight requests in the scheduler |
| `loki_query_scheduler_queue_duration_seconds` | Histogram | Time queries spend in the scheduler queue before being picked up |
| `loki_query_scheduler_connected_frontend_clients` | Gauge | Connected query frontend clients |
| `loki_query_scheduler_connected_querier_clients` | Gauge | Connected querier clients |
| `loki_query_scheduler_running` | Gauge | Whether the scheduler is running |

## Querier

Queriers execute LogQL queries against ingesters and the store. These metrics measure querier health and resource usage.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_querier_worker_concurrency` | Gauge | Configured worker concurrency |
| `loki_querier_worker_inflight_queries` | Gauge | Inflight queries per worker |
| `loki_querier_query_frontend_clients` | Gauge | Number of query frontend clients |
| `loki_querier_tail_active` | Gauge | Number of active tail requests |
| `loki_querier_tail_active_streams` | Gauge | Number of active tailed streams |
| `loki_querier_tail_bytes_total` | Counter | Total bytes sent via tail requests |
| `loki_querier_index_cache_hits_total` | Counter | Index cache hits |
| `loki_querier_index_cache_gets_total` | Counter | Index cache lookups |
| `loki_querier_index_cache_puts_total` | Counter | Index cache insertions |
| `loki_querier_index_cache_encode_errors_total` | Counter | Index cache encoding errors |
| `loki_querier_index_cache_corruptions_total` | Counter | Index cache corruption events |

## Chunk store

The store layer reads and deduplicates chunks from object storage. These metrics indicate storage performance and query efficiency.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_chunk_store_chunks_per_query` | Histogram | Number of chunks inspected per query |
| `loki_chunk_store_index_entries_per_chunk` | Histogram | Index entries per chunk |
| `loki_chunk_store_index_lookups_per_query` | Histogram | Index lookups performed per query |
| `loki_chunk_store_series_pre_intersection_per_query` | Histogram | Series count before intersection per query |
| `loki_chunk_store_series_post_intersection_per_query` | Histogram | Series count after intersection per query |
| `loki_chunk_store_deduped_chunks_total` | Counter | Total chunks deduplicated at read time |
| `loki_chunk_store_deduped_bytes_total` | Counter | Total bytes saved through deduplication |
| `loki_chunk_store_stored_chunks_total` | Counter | Total chunks stored |
| `loki_chunk_store_stored_chunk_bytes_total` | Counter | Total bytes stored in chunks |

## TSDB index

Loki uses TSDB-based index storage. These metrics capture index build and maintenance health.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_tsdb_build_index_attempts_total` | Counter | TSDB index build attempts by `status` (success, failure) |
| `loki_tsdb_build_index_last_successful_timestamp_seconds` | Gauge | Timestamp of the last successful index build |
| `loki_tsdb_head_rotation_attempts_total` | Counter | TSDB head rotation attempts by `status` |
| `loki_tsdb_head_series_not_found_total` | Counter | Series lookup misses in the TSDB head |
| `loki_tsdb_wal_truncation_attempts_total` | Counter | WAL truncation attempts by `status` |
| `loki_tsdb_shipper_tables_upload_operation_total` | Counter | TSDB index file uploads by `status` |
| `loki_tsdb_shipper_tables_download_operation_duration_seconds` | Gauge | Duration of index file download operations |
| `loki_tsdb_shipper_tables_sync_operation_total` | Counter | TSDB table sync operations by `status` |

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
| `loki_cache_request_duration_seconds` | Histogram | Cache request latency |
| `loki_cache_hits` | Counter | Total cache hits |
| `loki_cache_fetched_keys` | Counter | Total cache keys fetched |
| `loki_cache_corrupt_chunks_total` | Counter | Corrupt chunks detected in cache |
| `loki_cache_value_size_bytes` | Histogram | Size of cached values |
| `loki_embeddedcache_added_new_total` | Counter | New entries added to embedded cache |
| `loki_embeddedcache_entries` | Gauge | Current number of entries in embedded cache |
| `loki_embeddedcache_evicted_total` | Counter | Entries evicted from embedded cache |
| `loki_embeddedcache_memory_bytes` | Gauge | Current memory usage of embedded cache |

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
| `loki_ruler_managers_total` | Gauge | Number of registered rule managers |
| `loki_ruler_sync_rules_total` | Counter | Rule sync cycles by `reason` (initial, periodic) |
| `loki_ruler_config_last_reload_successful` | Gauge | Whether the last ruler config reload succeeded (1 = success, 0 = failure) |
| `loki_ruler_config_updates_total` | Counter | Rule config updates triggered by users |
| `loki_ruler_ring_check_errors_total` | Counter | Errors during ruler ring ownership checks |
| `loki_ruler_clients` | Gauge | Number of ruler clients in the connection pool |
| `loki_prometheus_rule_evaluation_duration_seconds` | Summary | Rule evaluation duration |
| `loki_prometheus_rule_group_duration_seconds` | Summary | Rule group evaluation duration |
| `loki_prometheus_notifications_sent_total` | Counter | Alert notifications sent to Alertmanager |
| `loki_prometheus_notifications_errors_total` | Counter | Alert notification errors |
| `loki_prometheus_notifications_dropped_total` | Counter | Alert notifications dropped |
| `loki_prometheus_notifications_queue_length` | Gauge | Current notification queue depth |
| `loki_prometheus_notifications_queue_capacity` | Gauge | Notification queue capacity |

## Ring / cluster membership

Loki uses a distributed hash ring for component discovery and ownership. These metrics measure cluster health.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_ring_members` | Gauge | Ring members by `name` (ingester, distributor, compactor, scheduler) and `state` (ACTIVE, JOINING, LEAVING, PENDING, Unhealthy) |
| `loki_ring_tokens_total` | Gauge | Number of tokens in the ring per component |
| `loki_ring_member_heartbeats_total` | Counter | Heartbeats sent by ring members |
| `loki_ring_member_tokens_owned` | Gauge | Tokens owned by each ring member |
| `loki_ring_member_tokens_to_own` | Gauge | Target tokens to own per ring member |
| `loki_ring_oldest_member_timestamp` | Gauge | Timestamp of the oldest member in the ring |

A ring health SLI (unhealthy members should be 0):

```promql
sum by (name) (loki_ring_members{state="Unhealthy"})
```

## MetaStore

The MetaStore resolves data ownership and partition metadata for Loki's sharded query execution.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_metastore_index_objects_total` | Histogram | Number of index objects resolved per operation |
| `loki_metastore_resolved_sections_total` | Histogram | Number of resolved storage sections per operation |
| `loki_metastore_resolved_sections_ratio` | Histogram | Ratio of resolved sections relative to total |
| `loki_metastore_estimate_sections_total_duration_seconds` | Histogram | Duration of section estimation operations |
| `loki_metastore_estimate_sections_pointer_read_duration_seconds` | Histogram | Pointer read duration during section estimation |
| `loki_metastore_stream_filter_total_duration_seconds` | Histogram | Duration of stream filter operations |
| `loki_metastore_stream_filter_sections_total` | Histogram | Number of sections scanned during stream filtering |
| `loki_metastore_stream_filter_streams_read_duration_seconds` | Histogram | Duration of stream reads during filtering |
| `loki_metastore_stream_filter_pointers_read_duration_seconds` | Histogram | Duration of pointer reads during stream filtering |

## Rate store

The rate store tracks per-stream ingestion rates and is used for rate limiting and stream sharding decisions.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_rate_store_streams` | Gauge | Number of tracked streams in the rate store |
| `loki_rate_store_stream_rate_bytes` | Histogram | Per-stream ingestion rate in bytes |
| `loki_rate_store_stream_shards` | Histogram | Number of shards per stream |
| `loki_rate_store_max_stream_rate_bytes` | Gauge | Maximum observed stream ingestion rate |
| `loki_rate_store_max_stream_shards` | Gauge | Maximum observed shard count |
| `loki_rate_store_max_unique_stream_rate_bytes` | Gauge | Maximum unique stream rate |
| `loki_rate_store_refresh_failures_total` | Counter | Refresh cycle failures |
| `loki_rate_store_refresh_duration_seconds` | Histogram | Duration of rate store refresh cycles |
| `loki_rate_store_expired_streams_total` | Counter | Expired stream entries removed |

## Compactor

The compactor merges TSDB index files and applies retention. These metrics measure compaction health.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_compactor_apply_retention_operation_duration_seconds` | Gauge | Duration of retention application |
| `loki_compactor_apply_retention_last_successful_run_timestamp_seconds` | Gauge | Timestamp of the last successful retention run |
| `loki_compactor_locked_table_successive_compaction_skips` | Counter | Consecutive compaction skips due to locked tables |
| `loki_boltdb_shipper_compact_tables_operation_duration_seconds` | Gauge | Duration of table compaction operations |
| `loki_boltdb_shipper_compact_tables_operation_last_successful_run_timestamp_seconds` | Gauge | Timestamp of the last successful table compaction |
| `loki_boltdb_shipper_compact_tables_operation_total` | Counter | Table compaction operations by `status` |
| `loki_boltdb_shipper_compactor_running` | Gauge | Whether the boltdb shipper compactor is currently running |

## Internal logging

These metrics track Loki's own logging subsystem health.

| Metric | Type | Description |
|--------|------|-------------|
| `loki_internal_log_messages_total` | Counter | Internal log messages by level |
| `loki_log_messages_total` | Counter | Log messages emitted by Loki components |
| `loki_log_flushes` | Histogram | Log flush duration |
| `loki_panic_total` | Counter | Total panics in Loki components |
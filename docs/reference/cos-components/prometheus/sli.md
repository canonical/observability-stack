---
myst:
  html_meta:
    description: "SLI metrics for monitoring Prometheus health using Sloth in the Canonical Observability Stack."
---

# Prometheus SLIs

This page documents Service Level Indicators (SLIs) and Service Level
Objectives (SLOs) for monitoring the health of Prometheus. To set up these
SLOs, see [Set up SLOs with Sloth](/how-to/integrate/set-up-slos-with-sloth).

These metrics are recommended as Service Level Indicators for Prometheus.

## Query performance

| Metric | Type | Description |
|--------|------|-------------|
| `prometheus_engine_query_duration_seconds` | Summary | Query execution time by slice (inner_eval, prepare_time, queue_time, result_sort) |
| `prometheus_engine_queries` | Gauge | Number of currently executing or waiting queries |
| `prometheus_engine_queries_concurrent_max` | Gauge | Maximum concurrent queries allowed |
| `prometheus_engine_query_samples_total` | Counter | Total samples loaded by all queries |

## HTTP API

| Metric | Type | Description |
|--------|------|-------------|
| `prometheus_http_request_duration_seconds` | Histogram | HTTP request latency by handler |
| `prometheus_http_requests_total` | Counter | HTTP requests by handler and status code |
| `prometheus_http_response_size_bytes` | Histogram | HTTP response size by handler |

## Scrape health

| Metric | Type | Description |
|--------|------|-------------|
| `up` | Gauge | Target reachability (1 = up, 0 = down) |
| `scrape_duration_seconds` | Gauge | Duration of the last scrape per target |
| `scrape_samples_scraped` | Gauge | Number of samples scraped per target |
| `prometheus_target_interval_length_seconds` | Summary | Actual interval between scrapes |

## Rule evaluation

| Metric | Type | Description |
|--------|------|-------------|
| `prometheus_rule_evaluations_total` | Counter | Total rule evaluations per rule group |
| `prometheus_rule_evaluation_failures_total` | Counter | Failed rule evaluations per rule group |
| `prometheus_rule_evaluation_duration_seconds` | Summary | Rule evaluation duration |
| `prometheus_rule_group_iterations_total` | Counter | Total scheduled rule group evaluations |
| `prometheus_rule_group_iterations_missed_total` | Counter | Missed rule group evaluations due to slow evaluation |
| `prometheus_rule_group_duration_seconds` | Summary | Rule group evaluation duration |

## Alert notifications

| Metric | Type | Description |
|--------|------|-------------|
| `prometheus_notifications_sent_total` | Counter | Alerts sent to Alertmanager |
| `prometheus_notifications_dropped_total` | Counter | Alerts dropped due to send errors |
| `prometheus_notifications_errors_total` | Counter | Alerts affected by errors |
| `prometheus_notifications_queue_length` | Gauge | Alerts in queue per Alertmanager |
| `prometheus_notifications_latency_seconds` | Summary | Alert notification send latency |

## Storage (TSDB)

| Metric | Type | Description |
|--------|------|-------------|
| `prometheus_tsdb_head_series` | Gauge | Number of active time series |
| `prometheus_tsdb_head_chunks` | Gauge | Number of chunks in the head block |
| `prometheus_tsdb_compaction_duration_seconds` | Histogram | Time spent in compactions |
| `prometheus_tsdb_wal_corruptions_total` | Counter | WAL corruption events (should be 0) |
| `prometheus_tsdb_head_chunks_storage_size_bytes` | Gauge | Storage used by head block |

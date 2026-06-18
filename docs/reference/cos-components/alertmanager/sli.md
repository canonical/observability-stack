---
myst:
  html_meta:
    description: "SLI metrics for monitoring Alertmanager health using Sloth in the Canonical Observability Stack."
---

# Alertmanager SLIs

This page documents Service Level Indicators (SLIs) for monitoring the health of Alertmanager.
To set up Service Level Objectives (SLOs), see [Set up SLOs with Sloth](/how-to/integrate/set-up-slos-with-sloth).

These metrics are recommended as Service Level Indicators for Alertmanager.

## Alert ingestion

Alertmanager receives alerts from Prometheus and other senders. These metrics capture the health of the ingestion pipeline.

| Metric | Type | Description |
|--------|------|-------------|
| `alertmanager_alerts` | Gauge | Number of alerts by state (`active`, `suppressed`, `unprocessed`) |
| `alertmanager_alerts_received_total` | Counter | Total alerts received, labelled by `status` (firing, resolved) and `version` (v2) |
| `alertmanager_alerts_invalid_total` | Counter | Alerts rejected due to invalid format; should remain at 0 |
| `alertmanager_marked_alerts` | Gauge | Number of alerts by state as tracked by the marker, regardless of expiry |

The primary availability SLI for alert ingestion is the ratio of valid to total received alerts:

```promql
1 -
(
  sum(rate(alertmanager_alerts_invalid_total[5m]))
  /
  sum(rate(alertmanager_alerts_received_total[5m]))
)
```

The number of active alerts can also be monitored to detect alert storms or missing silences:

```promql
alertmanager_alerts{state="active"}
```

## Notification delivery

Alertmanager dispatches alerts to configured receivers. Notification delivery is the core function — failures directly impact the ability of operators to respond to incidents.

| Metric | Type | Description |
|--------|------|-------------|
| `alertmanager_notifications_total` | Counter | Total notification attempts per integration (slack, pagerduty, email, webhook, etc.) |
| `alertmanager_notifications_failed_total` | Counter | Failed notifications per integration, labelled by `reason` (serverError, clientError, contextCanceled, contextDeadlineExceeded, other) |
| `alertmanager_notification_latency_seconds` | Histogram | Notification send latency per integration |
| `alertmanager_notification_requests_total` | Counter | Total notification HTTP requests per integration |
| `alertmanager_notification_requests_failed_total` | Counter | Failed notification HTTP requests per integration |

A notification delivery SLI by integration:

```promql
(sum by (integration) (rate(alertmanager_notifications_total[5m]))
-
sum by (integration) (rate(alertmanager_notifications_failed_total[5m])))
/
sum by (integration) (rate(alertmanager_notifications_total[5m]))
```

A latency SLI (P99 across all integrations):

```promql
histogram_quantile(0.99, sum by (le) (
  rate(alertmanager_notification_latency_seconds_bucket[5m])
))
```

## Dispatcher

The dispatcher routes incoming alerts to the correct aggregation groups and receivers. These metrics measure internal routing health.

| Metric | Type | Description |
|--------|------|-------------|
| `alertmanager_dispatcher_aggregation_groups` | Gauge | Number of active aggregation groups |
| `alertmanager_dispatcher_alert_processing_duration_seconds` | Summary | Latency of alert processing in the dispatcher |
| `alertmanager_dispatcher_aggregation_group_limit_reached_total` | Counter | Times the dispatcher failed to create a new aggregation group due to a limit |

## Silences

Silences suppress alert notifications based on matchers. These metrics measure the performance and health of the silence subsystem.

| Metric | Type | Description |
|--------|------|-------------|
| `alertmanager_silences` | Gauge | Number of silences by state (`active`, `pending`, `expired`) |
| `alertmanager_silences_query_duration_seconds` | Histogram | Duration of silence query evaluation |
| `alertmanager_silences_queries_total` | Counter | Total silence queries received |
| `alertmanager_silences_query_errors_total` | Counter | Silence queries that failed |
| `alertmanager_silences_matcher_compile_errors_total` | Counter | Silence matcher compilation failures, labelled by `stage` (index, load_snapshot) |
| `alertmanager_silences_gc_duration_seconds` | Summary | Duration of the last silence garbage collection cycle |
| `alertmanager_silences_gc_errors_total` | Counter | Silence garbage collection errors |

A silence query error SLI:

```promql
sum(rate(alertmanager_silences_query_errors_total[5m]))
/
sum(rate(alertmanager_silences_queries_total[5m]))
```

## HTTP API

Alertmanager exposes an HTTP API for alert management, status queries, configuration reload, and metrics scraping.

| Metric | Type | Description |
|--------|------|-------------|
| `alertmanager_http_request_duration_seconds` | Histogram | HTTP request latency by handler, method, and status code |
| `alertmanager_http_requests_in_flight` | Gauge | Current number of HTTP requests being processed |
| `alertmanager_http_response_size_bytes` | Histogram | HTTP response size by handler and method |
| `alertmanager_http_concurrency_limit_exceeded_total` | Counter | HTTP requests rejected due to concurrency limit, by method |

A latency SLI for the API (P99):

```promql
histogram_quantile(0.99, sum by (le) (
  rate(alertmanager_http_request_duration_seconds_bucket[5m])
))
```

## Configuration

Reload failures indicate a configuration error that prevents Alertmanager from applying changes. A successful reload is required to propagate routing and receiver changes.

| Metric | Type | Description |
|--------|------|-------------|
| `alertmanager_config_last_reload_successful` | Gauge | Whether the last configuration reload was successful (1 = success, 0 = failure) |
| `alertmanager_config_last_reload_success_timestamp_seconds` | Gauge | Timestamp of the last successful configuration reload |
| `alertmanager_config_hash` | Gauge | Hash of the currently loaded configuration |

A configuration reload SLI:

```promql
alertmanager_config_last_reload_successful
```

This should equal 1 at all times under normal operating conditions.

## Notification log

The notification log (`nflog`) records which notifications have been sent to avoid duplicates. These metrics capture the health of that persistence layer.

| Metric | Type | Description |
|--------|------|-------------|
| `alertmanager_nflog_maintenance_total` | Counter | Notification log maintenance cycles executed |
| `alertmanager_nflog_maintenance_errors_total` | Counter | Notification log maintenance cycles that failed |
| `alertmanager_nflog_gc_duration_seconds` | Summary | Duration of the last notification log garbage collection |
| `alertmanager_nflog_snapshot_duration_seconds` | Summary | Duration of the last notification log snapshot |
| `alertmanager_nflog_snapshot_size_bytes` | Gauge | Size of the last notification log snapshot |


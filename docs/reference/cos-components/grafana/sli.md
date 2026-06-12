---
myst:
  html_meta:
    description: "SLI metrics for monitoring Grafana health using Sloth in the Canonical Observability Stack."
---

# Grafana SLIs

This page documents Service Level Indicators (SLIs) for monitoring the health of Grafana.
To set up Service Level Objectives (SLOs), see [Set up SLOs with Sloth](/how-to/integrate/set-up-slos-with-sloth).

These metrics are recommended as Service Level Indicators for Grafana.

## HTTP API

| Metric | Type | Description |
|--------|------|-------------|
| `grafana_http_request_duration_seconds` | Histogram | HTTP request latency by handler, method, status code, and SLO group |
| `grafana_http_request_in_flight` | Gauge | Number of HTTP requests currently being served |
| `grafana_api_response_status_total` | Counter | API responses by HTTP status code |
| `grafana_page_response_status_total` | Counter | Page responses by HTTP status code |
| `grafana_proxy_response_status_total` | Counter | Proxy responses by HTTP status code |

## Datasource health

| Metric | Type | Description |
|--------|------|-------------|
| `grafana_datasource_request_duration_seconds` | Histogram | Datasource request latency by datasource, type, method, and status code |
| `grafana_datasource_request_total` | Counter | Datasource requests by datasource, type, method, and status code |
| `grafana_datasource_request_in_flight` | Gauge | Number of datasource requests currently in flight |

## Database

| Metric | Type | Description |
|--------|------|-------------|
| `grafana_database_conn_in_use` | Gauge | Number of database connections currently in use |
| `grafana_database_conn_idle` | Gauge | Number of idle database connections |
| `grafana_database_conn_wait_count_total` | Counter | Total number of times a request waited for a database connection |
| `grafana_database_conn_wait_duration_seconds` | Gauge | Total time blocked waiting for a database connection |

## Alerting

| Metric | Type | Description |
|--------|------|-------------|
| `grafana_alerting_active_alerts` | Gauge | Number of active alerts |
| `grafana_alerting_alerts` | Gauge | Number of alerts by state in the scheduler |
| `grafana_alerting_schedule_alert_rules` | Gauge | Number of alert rules considered for evaluation at the next tick |
| `grafana_alerting_execution_time_milliseconds` | Summary | Alert rule evaluation execution time |
| `grafana_alerting_notification_latency_seconds` | Summary | Alert notification send latency |

## Plugins

| Metric | Type | Description |
|--------|------|-------------|
| `grafana_plugin_request_duration_milliseconds` | Histogram | Plugin request duration by endpoint, plugin ID, and status |
| `grafana_plugin_request_total` | Counter | Plugin requests by endpoint, plugin ID, and status |

## Rendering

| Metric | Type | Description |
|--------|------|-------------|
| `grafana_rendering_queue_size` | Gauge | Number of rendering requests currently queued |

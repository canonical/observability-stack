# Telemetry labels

An application produces telemetry (metrics, logs, traces, profiles) which the observability stack collects and analyzes to surface issues and abnormalities. Telemetry coming from multiple sources (which could be on different nodes, or even infrastructure) is stored in a centralized database, therefore we need to be able to map the telemetry back to its origin.
This is the goal of **telemetry labels**.

A telemetry label is a key-value pair. Telemetry labels can be specified:
- **at generation time**: the instrumentation can attach the labels to the produced telemetry
- **at scrape time**: the scrape jobs can be configured to label the scraped telemetry by means of "scrape configs"

Telemetry labels are used throughout the [Grafana ecosystem](https://grafana.com/oss/) to uniquely identify the source of a piece of data.

## Metric labels

By convention, applications expose labeled metrics under a [`/metrics` endpoint](https://github.com/prometheus/OpenMetrics/blob/main/specification/OpenMetrics.md).
For example, you can run the prometheus application and curl its `:9090/metrics` endpoint to obtain the metrics exposed by the process.

```bash
$ sudo snap install prometheus

$ curl localhost:9090/metrics

# -- snip --

# HELP process_open_fds Number of open file descriptors.
# TYPE process_open_fds gauge
process_open_fds 14

# -- snip --

# HELP prometheus_http_requests_total Counter of HTTP requests.
# TYPE prometheus_http_requests_total counter
prometheus_http_requests_total{code="200",handler="/metrics"} 128
prometheus_http_requests_total{code="302",handler="/"} 1

# ...
```

In the example above,
- `process_open_fds` is a metric without any labels
- `prometheus_http_requests_total` is a metric with two labels: 
  - `code`: a label that tells you the status code of a handled request 
  - `handler`: a label that tells you the path of the endpoint handling an HTTP request

## Scrape job labels for metrics

While metric labels are set by the app developer, each scrape job configured on the monitoring service can append an additional fixed set of labels to all the metrics it collects.
Prometheus and grafana agent are two examples of monitoring services capable of scraping metrics.

For prometheus (or grafana agent) to scrape our apps (targets), we need to specify in its configuration file where to find them. This is also where we specify telemetry labels.

```yaml
scrape_configs:
  - job_name: "some-app-scrape-job"
    metrics_path: "/metrics"
    static_configs:
      - targets: ["hostname.for.my.app:8080"]
        labels:
          location: "second_floor_third_server_from_the_left"
          purpose: "weather_station_cluster"
```

Labels that are specified under a `static_configs` entry are automatically attached to all metrics scraped from the targets:

```bash
$ curl -s --data-urlencode 'match[]={__name__="prometheus_http_requests_total"}' localhost:9090/api/v1/series | jq '.data'
[
  {
    "__name__": "prometheus_http_requests_total",
    "code": "200",
    "handler": "/metrics",
    "instance": "localhost:9090",
    "job": "prometheus",
    "location": "second_floor_third_server_from_the_left",
    "purpose": "weather_station_cluster"
  },
  {
    "__name__": "prometheus_http_requests_total",
    "code": "302",
    "handler": "/",
    "instance": "localhost:9090",
    "job": "prometheus",
    "location": "second_floor_third_server_from_the_left",
    "purpose": "weather_station_cluster"
  },
]
```

Similarly, "service labels" can be specified using prometheus [remote-write endpoint](https://prometheus.io/docs/prometheus/latest/querying/api/#remote-write-receiver) and [push-gateway](https://github.com/prometheus/pushgateway/blob/master/README.md#use-it), and grafana agent's [config file](https://grafana.com/docs/agent/latest/static/configuration/metrics-config/).


## Log labels
Logs ("streams") ingested by Loki will be searchable by the specified labels.
If you [push logs directly to Loki](https://grafana.com/docs/loki/latest/reference/loki-http-api/#ingest-logs), you can attach labels to every "stream" pushed.
In Loki's terminology, a stream is a set of log lines pushed in a single request:
```json
{
  "streams": [
    {
      "stream": {
        "label": "value"
      },
      "values": [
          [ "<unix epoch in nanoseconds>", "<log line>" ],
          [ "<unix epoch in nanoseconds>", "<log line>" ]
      ]
    }
  ]
}
```

all of the labels specified in the `stream` section above will be applied to all the log lines specified in the `values` block.


## Scrape job labels for logs
Log files can be scraped by Promtail or grafana agent, which then stream the log lines to Loki using Loki's `push-api` endpoint.
Promtail, similar to grafana agent, has a [`scarpe_configs` section in its config file](https://grafana.com/docs/loki/latest/send-data/promtail/configuration/#scrape_configs) for specifying targets (log filename) and associate labels to them.
See also grafana agent's [config file](https://grafana.com/docs/agent/latest/static/configuration/logs-config/) docs.


## Alert labels
By design, prometheus (and Loki) store all [alerts](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/) in a centralized fashion: if you want your alerts to be evaluated, you must place them on the filesystem somewhere accessible by prometheus, and specify that path in Prometheus's [config file](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file):

```yaml
rule_files:
  - /path/to/*.rules
  - /another/one/*.yaml
```

Alert definitions are not tied to any particular node, application or metric.
This gives high flexibility in defining an alert. You could define an alert that triggers for any node that runs out of space, and another alert that triggers only for a specific application on a specific node. Narrowing down the scope of an alert is accomplished by using telemetry labels.

- `expr: process_cpu_seconds_total > 0.12`  would trigger if the value of any metric with this name (regardless of any labels) exceeds `0.12`.
- `expr: process_cpu_seconds_total{region="europe", app="nginx"} > 0.12`  would trigger only for this metrics that is also labeled as `nginx` and `europe`.

When an on-caller receives an alert (via [alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/), [karma](https://github.com/prymitive/karma) or similar), they see a rendering of the alert, which includes the `expr` and label values, among a few additional fields.

Additional alert labels can be specified in the alert definition:
```yaml
      labels:
        severity: critical
```

This is useful for:
- Filtering alert rules (see [grouping](https://prometheus.io/docs/alerting/latest/alertmanager/#grouping), [inhibition](https://prometheus.io/docs/alerting/latest/alertmanager/#inhibition), [silences](https://prometheus.io/docs/alerting/latest/alertmanager/#silences)).
- Enriching the message an on-caller sees with additional metadata.


## Relabeling
[`relabel_configs`](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config) and [`metric_relabel_configs`](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#metric_relabel_configs) are for modifying label and metric names, respectively.

See also:
- [reference/juju-topology-labels](Juju topology labels)
- [How relabeling in Prometheus works](https://grafana.com/blog/2022/03/21/how-relabeling-in-prometheus-works)
- [PromLens Relabeler](https://relabeler.promlabs.com/).

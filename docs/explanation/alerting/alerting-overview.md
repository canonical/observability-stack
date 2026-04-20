---
myst:
 html_meta:
  description: "Overview of alert rules, their objectives, and the different alert types that COS supports, along with an intro of each."
---

# Alert rules

Alert rules define the conditions under which COS raises alerts based on
metrics or logs collected from workloads. When a condition is met for a
specified period, a rule produces an alert, which is then routed by
Alertmanager to the configured receivers. This notifies admins of events that require immediate attention, such as low disk space, excessive memory use, or an unreachable monitored instance. COS has built-in support for alert rules based on metrics and logs.

## Overview

Alert rules are stored in YAML files and grouped by name. Each rule contains an expression that is evaluated on a schedule; when the expression is true for long enough (the `for` duration), the alert transitions from `pending` to `firing` and Alertmanager routes a notification to the configured channels such as PagerDuty.

Each rule carries metadata such as a name, severity label, and human-readable annotations that Alertmanager and Grafana use to present actionable notifications. In COS, the [Juju topology](/explanation/architecture/juju-topology.md) is used to annotate alert rules with identifiers such as `juju_application`, `juju_model`, `juju_model_uuid`, `juju_unit`, and `juju_charm`. COS supports alerts based on metrics and logs, commonly referred to as PromQL and LogQL rules respectively.

There is no official centralized store for alert rules; the [Awesome Prometheus Rules](https://samber.github.io/awesome-prometheus-alerts/) project is a commonly used starting point for generic rules. Because alerting thresholds and priorities vary across teams and workloads, a one-size-fits-all ruleset is not used, however, with COS and charmed operators, teams can ship their own alert rules alongside their workloads and have them automatically loaded into COS without manual configuration.

## Sources of alert rules

COS alert rules come from three sources:

### Generic alert rules

Generic rules are a minimal set of host-health rules shipped with COS itself, covering common failure scenarios such as unreachable targets and missing metrics. They require no configuration and apply automatically across deployments. The main focus of these alerts is the health of COS itself, as well as the reachability and `up` status of monitored instances. See [Generic alert rule groups](./generic-rules) for the full list and their behaviour.

### Charmed alert rules

Charmed rules are bundled directly with a charmed operator, encoding the operational knowledge its author considers important. They are automatically forwarded to Prometheus, Mimir, or Loki over Juju relations when the charm is deployed. They are written by the authors of charms monitored by COS and, unlike generic rules, they focus on specific workload-related health metrics. See [Charmed alert rules](./charmed-rules) for how they are transformed and managed.

### COS config charm

Custom alert rules can be loaded into COS from an external Git repository using the [COS Configuration charm](https://charmhub.io/cos-configuration-k8s). This is the recommended approach for organisation-specific or workload-specific rules that are not bundled with a charm. See [How to sync alert rules from a Git repository](../../how-to/configure-and-tune/sync-alert-rules-from-git) for setup instructions.

## Type of alert rule

### Metrics-based (PromQL)

PromQL (Prometheus Query Language) is used to write alert rules that operate on metrics. These rules are evaluated by Prometheus and Mimir. An expression selects one or more time series and applies filters, aggregations, or arithmetic to produce a scalar result. When the result satisfies the condition (e.g. `> 0.5`), the alert fires.

A typical PromQL alert rule looks like this:

```yaml
alert: HighErrorRate
expr: |
  rate(http_requests_total{status=~"5.."}[5m])
    /
  rate(http_requests_total[5m])
    > 0.05
for: 10m
labels:
  severity: critical
annotations:
  summary: "High HTTP 5xx error rate on {{ $labels.job }}"
  description: "More than 5% of requests are returning 5xx for the past 10 minutes."
```

Here, `rate(...)` computes the per-second rate of requests over a 5-minute window. Dividing error requests by all requests gives a ratio; the alert fires only when that ratio exceeds 5% for 10 consecutive minutes.

For more information on PromQL, refer to the official Prometheus docs on [querying](https://prometheus.io/docs/prometheus/latest/querying/basics/).

### Logs-based (LogQL)

LogQL is Loki's query language for log streams. These rules are evaluated by Loki. Alert rules using LogQL are called *log alerts* and rely on metric queries. Log lines are counted or sampled over a time window to produce a numeric value that can be compared against a threshold.

A typical LogQL alert rule looks like:

```yaml
alert: HighLogErrorRate
expr: |
  sum(rate({job="my-service"} |= "error" [5m])) > 10
for: 5m
labels:
  severity: warning
annotations:
  summary: "Elevated error log rate for {{ $labels.job }}"
  description: "More than 10 error log lines per second have been observed for 5 minutes."
```

Here, `rate(...)` counts log lines matching the filter `|= "error"` per second over a 5-minute window, then `sum(...)` aggregates across all streams for the job. The alert fires when that rate exceeds 10 for 5 continuous minutes.

For more information on LogQL, refer to the official Grafana docs on [Loki queries](https://grafana.com/docs/loki/latest/query/).
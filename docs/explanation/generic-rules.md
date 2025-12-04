# Generic alert rule groups
The Canonical Observability Stack (COS) includes Generic alert rules which provide a minimal set of rules to inform admins when hosts in a deployment are unhealthy, unreachable, or otherwise unresponsive. This helps relieve charm authors from having to implement their host-health-related alerts per charm. 
There are two generic alert rule groups: `HostHealth` and `AggregatorHostHealth`, each containing multiple alert rules.
This guide explains the purpose of each rule group and its alerts. For steps to troubleshoot firing alert rules, refer to the [troubleshooting guide](../how-to/troubleshooting/troubleshoot-firing-alert-rules.md).

The `HostHealth` and `AggregatorHostHealth` alert rule groups are applicable to the following deployment scenarios:

```{mermaid}
graph LR

subgraph lxd
vm-charm1 ---|cos_agent| grafana-agent
vm-charm2 ---|monitors| cos-proxy
end

subgraph k8s
k8s-charm1 ---|metrics_endpoint| prometheus
k8s-charm2 ---|metrics_endpoint| grafana-agent-k8s
grafana-agent-k8s ---|prometheus_remote_write| prometheus
end

grafana-agent ---|prometheus_remote_write| prometheus
cos-proxy ---|metrics_endpoint| prometheus
```
You can find more information on these groups and the alert rules they contain below.

## `HostHealth` alert group
The `HostHealth` alert rule group contains the `HostDown` and `HostMetricsMissing` alert rules, identifying unreachable target scenarios.

### `HostDown` alert rule
The `HostDown` alert rule is directly applicable to cases where a charm is being scraped by Prometheus for metrics. This rule notifies you when Prometheus (or Mimir) fails to scrape its target. The alert expression executes `up{...} < 1` with labels including the target's Juju topology: `juju_model`, `juju_application`, etc. The [`up` metric](https://prometheus.io/docs/concepts/jobs_instances/), which is what this alert's expression relies on, indicates the health or reachability status of a node. For example, when `up` is 1 for a charm, this is a sign that Prometheus is able to successfully call the metrics endpoint of that charm and access the metrics that are exposed at that endpoint.

This alert is especially important for COS Lite, where Prometheus is capable of scraping charms for metrics. The firing of this alert indicates that Prometheus is not able to scrape a target for metrics, leading to `up` being 0.


### `HostMetricsMissing` alert rule
```{note}
`HostMetricsMissing` is also used in the `AggregatorHostHealth` group. As part of the `HostHealth` group, however, it monitors the health of any charm (not just aggregators) whose metrics are collected by an aggregator and then remote written to a metrics backend. See the `AggregatorHostHealth` group for details on the distinction.
```

This alert notifies you when metrics are not reaching the Prometheus (or Mimir) database, regardless of whether scrape succeeded. The alert expression executes `absent(up{...})` with labels including the aggregator's Juju topology: `juju_model`, `juju_application`, `juju_unit`, etc. 

Like the `HostDown` rule, this rule gives you an idea of the health of a node and whether it is reachable. However, unlike `HostDown`, `HostMetricsMissing` is used in scenarios where metrics from a charm are remote written into Prometheus or Mimir, as opposed to being scraped. This rule is especially important in COS, where the use of Mimir instead of Prometheus warrants metrics to be remote written (as Mimir does not scrape).

To provide an example that distinguishes between `HostDown` and `HostMetricsMissing`, consider how the health of Alertmanager can be monitored in different deployment scenarios below:

- In COS Lite, metrics from Alertmanager are scraped by Prometheus. A successful scrape results in `up` = 1 and a failed scrape results in `up` = 0. As a result, we can rely on the `HostDown` alert to notify in case of issues with the scrape i.e. when `up` is 0.
- In COS HA, a collector such as `opentelemetry-collector` scrapes Alertmanager and then remote writes the collected metrics into Mimir. In this scenario, in Mimir, we either have an `up` of 1 or an absent `up` altogether. Here, we need the `HostMetricsMissing` alert to be aware of the health of Alertmanager. Note that it is possible that the scrape of Alertmanager being made by the aggregator is successful and that `up` is missing because the aggregator is failing to remote write what it has scraped.

## `AggregatorHostHealth` alert group
The `AggregatorHostHealth` alert rule group focuses explicitly on the health of aggregators (remote writers), such as `opentelemetry-collector` and `grafana-agent`. This group contains the `HostMetricsMissing` and the `AggregatorMetricsMissing` alert rules.

### `HostMetricsMissing` alert rule
The `HostMetricsMissing` alert rule fires when metrics are not reaching the Prometheus (or Mimir) database, regardless of whether scrape succeeded. The alert expression executes `absent(up{...})` with labels including the aggregator's Juju topology: `juju_model`, `juju_application`, `juju_unit`, etc. However, when it comes to aggregators, this rule indicates whether alerts from a collector itself are reaching the metrics backend.

When you have an aggregator charm (e.g. `opentelemetry-collector` or `grafana-agent`), this alert is duplicated per unit of that aggregator so that it identifies if a unit is missing a time series. For example, if you have 2 units of `opentelemetry-collector`, and one is behind a restrictive firewall, you should receive only one firing `HostMetricsMissing` alert.

```{note}
By default, the severity of this alert is `warning`. However, when this alert is for a subordinate remote-writing machine charm, its severity is increased to `critical`.
```

### `AggregatorMetricsMissing` alert rule
Similar to `HostMetricsMissing`, this alert is applied to aggregators to ensure their `up` metric exists. The difference, however, is that `AggregatorMetricsMissing` **triggers only when *all units* of an aggregator are down**. For this reason, the alert expression executes `absent(up{...})` with labels including the aggregator's Juju topology: `juju_model`, `juju_application`, but leaves out `juju_unit`. If you have 2 units of an aggregator and the `up` metric is missing for both, this alert will fire.

```{note}
By default, the severity of this alert is **always** `critical`.
```


# Troubleshoot `AggregatorHostHealth` alert rules

The `AggregatorHostHealth` alert rule group contains both the `HostMetricsMissing` and the `AggregatorMetricsMissing` alert rules, identifying unreachable target scenarios. It is somewhat similar to the `HostHealth` alert group, but it focuses explicitly on the health of aggregators (AKA remote writers).
Similar to the `HostHealth` alert rule group, this rule group relies on generic (synthetically generated) alert rules, alleviating charm authors from having to implement their own `AggregatorHostHealth` rules, per charm, reducing implementation error.

The purpose of this alert group is to monitor the health of aggregators remote writers() such as `opentelemetry-collector` or `grafana-agent`. 

The `AggregatorHostHealth` alert rule group is applicable to the following deployment scenarios:

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

## `HostMetricsMissing` alert
The purpose of this alert is to notify when metrics are not reaching the Prometheus (or Mimir) database, regardless of whether scrape succeeded. The alert expression executes `absent(up{...})` with labels including the aggregator's Juju topology: `juju_model`, `juju_application`, `juju_unit`, etc. 

When you have an aggregator charm (e.g. Opentelemetry Collector or Grafana Agent), this alert is duplicated per each unit of that aggregator. This means that for an aggregator, this alert identifies the `up` status of each unit. For example, if you have 3 units of `opentelemetry-collector` and 2 of them are down, you should receive two firing `HostMetricsMissing` alerts.

```{note}
By default, the severity of this alert is `warning`. However, when this alert concerns a subordinate machine charm, its severity is increased to `critical`.
```

## `AggregatorMetricsMissing` alert
Similar to `HostMetricsMissing`, this alert is a generic rule that is applied to aggregators to ensure their `up` status. The difference, however, is that `AggregatorMetricsMissing` will fire when _ALL_ units of an aggregator are down. If you have 4 units of an aggregator and the `up` metric is missing for all four of them, this alert will be triggered.

```{note}
By default, the severity of this alert is **always** `critical`.
```

## How to troubleshoot this alert group
As mentioned before, the `HostMetricsMissing` and `AggregatorMetricsMissing` alerts are similar, with only differences in their severity and that the units they impact. As such, the methods to troubleshoot them are similar.

### Confirm the aggregator is running
Use `juju ssh` to check if the workload is running:
- run `snap list` for machine charms. Ensure the snap is `active`.
- run `pebble services` for k8s charms. Ensure the workload is `active`.

### Confirm the backend is reachable
It is possible that the aggregator is running, but failing to remote write metrics into the metrics backend. This can occur if there are network or firewall issues, leaving the aggregator unable to successfully hit the metrics backend's remote write endpoint.
The causes in these cases can often be revealed by looking at the workload logs and looking for logs that suggest issues in reaching a host. The logs will often mention timeouts, DNS name resolution failures, TLS certificate issues, or more broadly "export failures".
1. for machine aggregators, run `sudo snap logs <snap-name>`.
2. for K8s aggregators, use `juju ssh` and `pebble logs` to view the workload logs. For example, for `opentelemetry-collector-k8s` unit 0, you will need to look at the Pebble logs in the `otelcol` container: `juju ssh -c otelcol opentelemetry-collector/0`.

In some cases, the backend may be unreachable due to SSL/TLS related issues. This often happens when your aggregator is located outside the Juju model where your COS instance lives and your are using TLS communication when the aggregator tries to reach the backend (AKA external or full TLS). If you are using ingress, it is required for the aggregator to trust the CA that signed the backend or ingress provider (e.g. Traefik).  

### Inspect existing `up` time series
Perhaps the metrics *do* reach Prometheus, but the `expr` labels we have rendered in the alert do not match the actual metric labels. You can confirm by going to the Prometheus (or Grafana) UI and querying for `up`. Compare the set of labels you get for the returned `up` time series.




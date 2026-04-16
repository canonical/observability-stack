---
myst:
 html_meta:
  description: "Juju topology labels identify models, charms, and units to contextualize metrics, logs, traces, and dashboards in COS Lite."
---

# Juju Topology Labels

Juju topology labels are [telemetry labels](https://discourse.charmhub.io/t/telemetry-labels-in-the-grafana-ecosystem/8873) that are used for identifying the origin of metrics and logs in juju models. In other words, the Juju topology labels are a fingerprint of a unit in some juju model that is emitting telemetry. Especially when you have hundreds, thousands of nodes, it is essential to be able to locate that one unit that has been causing your alerts to go off.
Therefore, Juju topology labels play a key role in the Canonical observability stack (COS).

This is what the Juju topology labels look like:

```yaml
        labels:
          model: "some-juju-model"
          model_uuid: "00000000-0000-0000-0000-000000000001"
          application: "fancy-juju-application"
          unit: "fancy-juju-application/0"
          charm_name: "fancy-juju-application-k8s"
```

The COS charm libraries wrapping any observability relation endpoint inject these labels into all outgoing metric, log, trace, and dashboard, so that the charm using them doesn't have to be aware of this at all. Any charm can ship with dashboards and (alert) rules to monitor its lifecycle. These are the so-called "built-in" dashboards and rules, and are workload-specific. When the charm is deployed and related to COS, the charm libraries mediating the COS integrations will automatically inject the juju topology labels in all built-in dashboards and rules.

The following sections outline what this means in practice, and which juju-topology-related modifications are applied to the built-in rules and dashboards.

## Dashboards
Depending on whether the charm (where the dashboards reside) is related directly to `grafana-k8s`, or whether the data flows through `opentelemetry-collector` or `cos-proxy`, there are subtle differences in how the topology is injected.

### Charms relating directly to `grafana-k8s`
Built-in dashboards are enriched with topology drop-downs. This allows filtering dashboard data by topology labels. You can opt out of this behavior by calling a `._reinitialize_dashboard_data(inject_dropdowns=False)` method on the `GrafanaDashboardProvider` relation wrapper object.

### Charms relating through `cos-configuration`
Incidental dashboards coming in from a git repository via the `cos-configuration` charm are left intact.

### Charms relating through `opentelemetry-collector` (`-k8s` or not)
When dashboards are forwarded through a `opentelemetry-collector` intermediary, the juju topology labels of the charm of origin are injected (and not `opentelemetry-collector`'s). Any subsequent chaining to additional opentelemetry collectors charms would leave the labels intact.

### Charms relating through `cos-proxy`
`cos-proxy` will apply its own topology to the labels, as old LMA-provider units don't implement the more modern interfaces that we would need to add topology to the telemetry.

## Metrics
Metrics are workload-specific and vary from charm to charm.

### Charms relating through `opentelemetry-collector` (`-k8s` or not)
For `opentelemetry-collector`: any metrics coming from the principal charm will be tagged with the topology of the principal unit. The generic Linux metrics coming from the node exporter will be tagged with the opentelemetry-collector unit topology.

For `opentelemetry-collector-k8s`:  all metrics going through the charm are left unchanged.

### Charms relating through `cos-proxy`
`cos-proxy` will apply its own topology to the metrics.

## Alert rules
Alert rules are workload-specific and vary from charm to charm. For example, two different workloads can have an alert for "memory running out", but with different thresholds. We need to qualify each alert rule with a different set of labels, so that when an `expr` evaluates as true, it only fires for the intended metrics.

For built-in alert rules,

- Alert `expr`s are qualified with topology labels. This way, built-in alerts fire only for the particular charm they originated from.
- Alert labels are enriched with topology labels. This is meant for convenient reading of a rendered alert when presented to an on-caller. The labels would also be visible in the alert's rendered `expr`, but alert labels are more convenient to read.
- Alert rules are NOT enriched with the `unit` label. This is because we wouldn't want to replicated all rules per unit. Unit information is included in metric and log labels. Since alert rules are forwarded to prometheus/loki per related *app*, not unit, having multiple units does not result in prometheus having duplicated alerts per unit. If an alert was qualified with a unit (which one?), we wouldn't get alerts from any other units.
- Alert rules descriptions can use a  `{{ $labels.juju_unit }}` macro in the alert's annotations, which will be replaced with the unit name for better readability.

### Charms relating through `cos-configuration`
Incidental rule files coming in from a git repository via the `cos-configuration` charm are left untouched and forwarded as-they-are.

### Charms relating through `opentelemetry-collector` (`-k8s` or not)
When rule files are forwarded via opentelemetry-collector, then they are enriched with juju topology labels of the relating charm (not opentelemetry collector's topology). Any subsequent chaining to additional opentelemetry collector charms would leave the labels intact.

Alerts coming from opentelemetry-collector itself will be tagged with the opentelemetry-collector unit topology.

### Charms relating through `cos-proxy`
`cos-proxy` will apply its own topology to the rules.

## Logs
K8s charms can stream logs to loki using the charm lib. Behind the scenes this is accomplished using `promtail`, and log streams are enriched with juju topology labels.

### Charms relating through `opentelemetry-collector` (`-k8s` or not)
In `opentelemetry-collector`, logs scraped from files, such as `/var/log`, will be tagged with the opentelemetry-collector's own topology, while logs coming from the snap's slot will be tagged with the source unit's topology.

In `opentelemetry-collector-k8s`, the charm will not modify the topology.

### Charms relating through `cos-proxy`
`cos-proxy` will apply its own topology to the logs.

## Traces
Any charm can stream traces to Tempo using the `tracing` charm lib. Usually this is done by sending the traces to a `opentelemetry-collector`, which forwards them to the COS stack. The agent will be responsible to attach to any trace going through it the juju topology of the unit generating them, if known, or else its own (for uncharmed workloads).

In the rather exceptional case in which a charm is related directly to Tempo, the charm itself is responsible for configuring its workload to inject the juju topology of the unit in the traces.
This is the case, for example, for all COS components.

### Charms relating directly to Tempo via `tracing`
If going via opentelemetry-collector is not an option for you, you are yourself responsible for injecting juju topology into the root span's resource definition. As your workload will be forwarding traces straight into Tempo, and Tempo doesn't know where they are coming from, you should ensure that you can see that clearly in the spans themselves.

## Additional notes
- In the future, the `cos-configuration` charm may start exposing metrics and logs generated by its own workload, `git-sync`, and those *would* be enriched by juju topology labels.

## See also
- [Model-driven observability: the magic of Juju topology for metrics](https://ubuntu.com/blog/model-driven-observability-part-2-juju-topology-metrics)

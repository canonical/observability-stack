# How to correlate node-exporter metrics with multiple co-located VM charms

The OpenTelemetry Collector (`otelcol`) charms deploy `node-exporter` as a singleton snap on a given machine. Additionally, multiple principal charms may be co-located on the same machine.

When `node-exporter` metrics are forwarded by `otelcol`, they include labels that identify the machine where the metrics were collected. Since these labels are shared by all charms running on that machine, there is no obvious way to correlate those metrics to the charms running on that machine.

This document describes how to perform that correlation.

## Manually, via label inspection

A `node-exporter` metric, such as `node_cpu_seconds_total`, is forwarded by `otelcol` with labels including `juju_model`, `juju_model_uuid` and `instance`. These labels are common to `otelcol` itself and any co-located charms.

The `juju_model` and `juju_model_uuid` labels identify the Juju model where the metric was collected. The `instance` label identifies the specific machine within that model where the metric was collected.

Note that the `juju_charm` and `juju_application` labels in these metrics refer to `otelcol` itself, not to the co-located principal charms -- which is precisely the problem this guide addresses.

For example, in the following `node-exporter` metric:

```
node_cpu_seconds_total{
  cpu="7",
  instance="juju-b2b564-0.lxd",
  job="juju_welcome-lxd_377f2555_otelcol1_node-exporter",
  juju_application="otelcol1",
  juju_charm="opentelemetry-collector",
  juju_model="welcome-lxd",
  juju_model_uuid="377f2555-db6c-4b2b-89c9-422668b2b564",
  mode="user"
}
```

The instance is `juju-b2b564-0.lxd`. Now, you can query for the application metrics you are interested in, filtering results with the label matcher `instance="juju-b2b564-0.lxd"`.

## Project charm labels onto node-exporter metrics

Every unit of `otelcol` exports an info gauge via the `node-exporter` textfile collector. For each principal unit related to `otelcol` (via `cos-agent` or `juju-info`), a metric line is generated. As seen in Prometheus, the metric looks as follows:

```
otelcol_subordinate_charm_info{
  otelcol_app="otelcol1",
  otelcol_unit="otelcol1/0",
  related_app="ubuntu1",
  related_unit="ubuntu1/0",
  instance="juju-b2b564-0.lxd",
  job="juju_welcome-lxd_377f2555_otelcol1_node-exporter",
  juju_application="otelcol1",
  juju_charm="opentelemetry-collector",
  juju_model="welcome-lxd",
  juju_model_uuid="377f2555-db6c-4b2b-89c9-422668b2b564"
}
```

The labels `otelcol_app` and `otelcol_unit` identify the subordinate collector unit. The labels `related_app` and `related_unit` identify the principal charm unit that `otelcol` is related to on that machine.

Use aggregation operators `on` and `group_right` to project labels from the info gauge onto the `node-exporter` metrics.

```
label_replace(
  label_replace(
    max without (cpu, mode) (
      rate(node_cpu_seconds_total[5m])*100
    ) * on(instance, juju_model, juju_model_uuid) group_right
    otelcol_subordinate_charm_info,
    "juju_application", "$1", "related_app", "(.*)"
  ),
  "juju_unit", "$1", "related_unit", "(.*)"
)
```

Here is what is happening:

- `rate(node_cpu_seconds_total)` is the raw data we are interested in (times 100 to convert to percentage).
- `max without (cpu, mode)` is an aggregation that collapses the timeseries into a unique set, in preparation for the join (`group_right`).
- `on(instance, juju_model, juju_model_uuid) group_right` is a join operation that matches metric values by corresponding labels.
- The `label_replace` instructions replace the existing `juju_application` and `juju_unit` labels (from `otelcol`) with the `related_app` and `related_unit` labels (from the principal charm `otelcol` is related to).

## References
- Robust Perception, [Exposing the software version to Prometheus](https://www.robustperception.io/exposing-the-software-version-to-prometheus/), August 22, 2016.
- Julien Pivotto, Brian Brazil, [Prometheus Up & Running](https://www.oreilly.com/library/view/prometheus-up/9781098131135/), page 97.

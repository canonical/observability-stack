# How to correlate node-exporter metrics with multiple co-located VM charms

The otelcol charms deploy `node_exporter` as a singleton snap in a given machine
However, multiple principal charms may be co-located on the same machine.
This document shows how to correlate between node-exporter metrics and co-located charms.

## Manually, via label inspection
A node-exporter metric such as `node_cpu_seconds_total`, is forwarded by otelcol with labels `juju_model`, `juju_model_uuid` and `instance`, all of which are common to otelcol itself and any co-located charms. The `juju_charm` and `juju_application` labels for node-exporter metrics would have otelcol information.

Note the `instance` label. For example, in the following node-exporter metric, the instance is `juju-b2b564-0.lxd`:

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

Now you can query for the application metrics you are interested in, filtering results with the label matcher `instance="juju-b2b564-0.lxd"`.

## Project charm labels onto node-exporter metrics
Every unit of otelcol renders "annotations" that look as follows:

```
subordinate_charm_info{
  collector_unit="otelcol1/0",
  instance="juju-b2b564-0.lxd",
  job="juju_welcome-lxd_377f2555_otelcol1_node-exporter",
  juju_application="otelcol1",
  juju_charm="opentelemetry-collector",
  juju_model="welcome-lxd",
  juju_model_uuid="377f2555-db6c-4b2b-89c9-422668b2b564",
  related_unit="ubuntu1/0"
}
```

Use aggregation operators `on` and `group_right` to project labels from the annotation metric onto the node-exporter metrics.

```
label_replace(
  label_replace(
    max without (cpu, mode) (
      rate(node_cpu_seconds_total[5m])*100
    ) * on(instance, juju_model, juju_model_uuid) group_right 
    subordinate_charm_info,
    "juju_application", "$1", "related_unit", "([^/]+)/.*"
  ),
  "juju_unit", "$1", "related_unit", "(.*)"
)
```

Let's break this down:
- `rate(node_cpu_seconds_total)` is the raw data we're interested in (time 100 to convert to percentage).
- `max without (cpu, mode)` is an aggregation that is intended for "collapsing" the timeseries into a unique set, in preparation to the `join` (`group_right`).
- `on(instance, juju_model, juju_model_uuid) group_right`  is a "join" operation that matches metric values by corresponding labels.
- The `label_replace` instructions replace the existing `juju_application` and `juju_unit` labels (from otelcol) with the `related_unit` label (from the charm otelcol is related to).

## References
- Robust Perception, [Exposing the software version to Prometheus](https://www.robustperception.io/exposing-the-software-version-to-prometheus/), August 22, 2016.
- Julien Pivotto, Brian Brazil, [Prometheus Up & Running](https://www.oreilly.com/library/view/prometheus-up/9781098131135/), page 97.

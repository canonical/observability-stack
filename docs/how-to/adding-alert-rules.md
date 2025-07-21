# Adding alert rules

Support for providing alert rules through the relation is available
for [loki-k8s](https://charmhub.io/loki-k8s) and [prometheus-k8s](https://charmhub.io/prometheus-k8s), both directly and through 
intermediary charms like [grafana-agent-k8s](https://charmhub.io/grafana-agent-k8s) 
and [prometheus-scrape-config-k8s](https://charmhub.io/prometheus-scrape-config-k8s).

## Prerequisites

To be able to pass on alert rules, you also need to implement 
their corresponding telemetry relation interface, as well as instantiating 
their corresponding library classes. For Prometheus, the relation 
interface is either `prometheus_scrape` and `MetricsEndpointProvider`, 
or `prometheus_remote_write` and `RemoteWriteConsumer`.

For Loki, this is `loki_push_api` and either `LokiPushApiConsumer` 
or `LogProxyConsumer`. If both interfaces are implemented, it would 
roughly look as follows:

```yaml
provides:
    metrics-endpoint:
        interface: prometheus_scrape

requires:
    logging:
        interface: loki_push_api
```

## Create an alert rule

An alert rule consists of a name, an expression, a duration, as well 
as optionally a set of labels and annotations. In this how to, we'll 
use an alert rule for ``zinc-k8s``. For the sake of this how to, the 
details of the rule are of less importance. If you want to learn more 
about crafting alert rules, have a look at the official (Prometheus)[https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/] 
or [Loki](https://grafana.com/docs/loki/latest/alert/#alerting-rule-example) 
documentation.

```yaml

alert: ZincTargetMissing
expr: up == 0
for: 0m
labels:
    severity: critical
annotations:
    summary: Prometheus target missing (instance {{ $labels.instance }})
    description: |
        A Prometheus target has disappeared. An exporter might be crashed.
        VALUE = {{ $value }}\n LABELS = {{ $labels }}
```

Save the file in `./src/prometheus_alert_rules` for Prometheus, or `./src/loki_alert_rules` for Loki, using a file name ending with ``.rule``. 
Next time you pack and deploy your charm, the alert rules will be 
transferred over as you integrate it with something using a supported 
relation interface.

```{note}
Custom paths must be passed as an argument to the constructor (e.g. `alert_rules_path=./src/rules/loki`).
```
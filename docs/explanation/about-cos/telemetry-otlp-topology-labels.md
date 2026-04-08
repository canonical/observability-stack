# Opentelemetry Protocol (OTLP) Juju Topology Labels

This document focuses on telemetry labeling in the OTLP data model that is core to the opentelemetry-collector (K8s or VM) charm pipelines.

Juju topology labels identify where telemetry comes from in a Juju model:

- `juju_model`
- `juju_model_uuid`
- `juju_application`
- `juju_charm`
- `juju_unit`

This page explains where those labels are injected into the OTLP data model, and where they are expected to already exist.

## Why this matters

OTLP data is often mixed across many applications and models, and aggregated into an observability solution i.e., COS.
Without topology attributes, logs, metrics, and traces are much harder to filter, route, alert on, and correlate.
Some applications may already have [telemetry labels](telemetry-labels.md), and knowing the structure within the charm's pipelines is important for Juju admin operations like [filtering](../how-to/selectively-drop-telemetry-otelcol.md), [tiering](../how-to/tiered-otelcols.md), and debugging the pipeline with the `debug_exporter_for_TELEMETRY` [config options in the collector charm](https://charmhub.io/opentelemetry-collector-k8s/configurations?channel=dev/edge).

## Telemetry labels in the OTLP data model

If OTLP data enters the pipeline with existing labels, they will be preserved, unless overwritten with processors. In other words, it is the responsibility of charm developers to instrument their applications so that the expected Juju topology labels are present. This is often abstracted by charm libraries which do this internally. For self-monitoring of the collector itself, the `receivers` in the config file are instrumented with the charm's own topology. Alternatively, Juju admins can process telemetry with a collector charm.

## Manually pushing Juju topology-labeled telemetry to the collector

```bash
TIMESTAMP=$(date +%s)000000000

# Logs
curl -s -X POST http://localhost:4318/v1/logs \
  -H "Content-Type: application/json" \
  -d '{
  "resourceLogs": [{
    "resource": {
      "attributes": [
        {"key": "service.name", "value": {"stringValue": "opentelemetry-collector-k8s"}},
        {"key": "juju_model", "value": {"stringValue": "cos"}},
        {"key": "juju_model_uuid", "value": {"stringValue": "abcd1234-0000-0000-0000-000000000000"}},
        {"key": "juju_application", "value": {"stringValue": "opentelemetry-collector-k8s"}},
        {"key": "juju_unit", "value": {"stringValue": "opentelemetry-collector-k8s/0"}},
        {"key": "juju_charm", "value": {"stringValue": "opentelemetry-collector-k8s"}}
      ]
    },
    "scopeLogs": [{
      "logRecords": [{
        "timeUnixNano": "'"$TIMESTAMP"'",
        "body": {"stringValue": "Testing OTLP logs with juju topology"},
        "severityText": "INFO",
        "severityNumber": 9
      }]
    }]
  }]
}'

# Metrics
curl -s -X POST http://localhost:4318/v1/metrics \
  -H "Content-Type: application/json" \
  -d '{
  "resourceMetrics": [{
    "resource": {
      "attributes": [
        {"key": "service.name", "value": {"stringValue": "opentelemetry-collector-k8s"}},
        {"key": "juju_model", "value": {"stringValue": "cos"}},
        {"key": "juju_model_uuid", "value": {"stringValue": "abcd1234-0000-0000-0000-000000000000"}},
        {"key": "juju_application", "value": {"stringValue": "opentelemetry-collector-k8s"}},
        {"key": "juju_unit", "value": {"stringValue": "opentelemetry-collector-k8s/0"}},
        {"key": "juju_charm", "value": {"stringValue": "opentelemetry-collector-k8s"}}
      ]
    },
    "scopeMetrics": [{
      "metrics": [{
        "name": "test_gauge",
        "unit": "1",
        "gauge": {
          "dataPoints": [{
            "timeUnixNano": "'"$TIMESTAMP"'",
            "asDouble": 42.0,
            "attributes": [
              {"key": "endpoint", "value": {"stringValue": "/health"}}
            ]
          }]
        }
      }]
    }]
  }]
}'

# Traces
curl -s -X POST http://localhost:4318/v1/traces \
  -H "Content-Type: application/json" \
  -d '{
  "resourceSpans": [{
    "resource": {
      "attributes": [
        {"key": "service.name", "value": {"stringValue": "opentelemetry-collector-k8s"}},
        {"key": "juju_model", "value": {"stringValue": "cos"}},
        {"key": "juju_model_uuid", "value": {"stringValue": "abcd1234-0000-0000-0000-000000000000"}},
        {"key": "juju_application", "value": {"stringValue": "opentelemetry-collector-k8s"}},
        {"key": "juju_unit", "value": {"stringValue": "opentelemetry-collector-k8s/0"}},
        {"key": "juju_charm", "value": {"stringValue": "opentelemetry-collector-k8s"}}
      ]
    },
    "scopeSpans": [{
      "spans": [{
        "traceId": "0af7651916cd43dd8448eb211c80319c",
        "spanId": "b7ad6b7169203331",
        "name": "test-span",
        "kind": 1,
        "startTimeUnixNano": "'"$TIMESTAMP"'",
        "endTimeUnixNano": "'"$(( ${TIMESTAMP%000000000} + 1 ))000000000"'",
        "attributes": [
          {"key": "http.method", "value": {"stringValue": "GET"}},
          {"key": "http.target", "value": {"stringValue": "/health"}}
        ],
        "status": {"code": 1}
      }]
    }]
  }]
}'
```

## Mapping rules to the rules provider with Juju topology

Although, this is technically not a concern of the opentelemetry-collector pipeline, rules are core to the [OTLP charm library](https://github.com/canonical/charmlibs/tree/main/interfaces/otlp) which injects the rule provider's Juju topology into the rules. This enables downstream systems to keep alerting/rule scope aligned with the same origin metadata as telemetry. For example, the labeled rules indicate that they are specific to the `send` (`opentelemetry-collector-k8s`) application:

```{mermaid}
flowchart LR
    S["send<br>(otelcol)"] --(send-otlp)--> R["receive<br>(otelcol)"]
```

```yaml
groups:
- name: rules_faf8c6cc_send_Both_alerts
  rules:
  - alert: Alerting
    expr: (count_over_time({job=~".+", juju_application="send", juju_model="rules",
      juju_model_uuid="faf8c6cc-698e-4c9a-8c14-f5dec651cd62", juju_charm="opentelemetry-collector-k8s"}[30s])
      > 100)
    labels:
      juju_application: send
      juju_charm: opentelemetry-collector-k8s
      juju_model: rules
      juju_model_uuid: faf8c6cc-698e-4c9a-8c14-f5dec651cd62
      juju_unit: send/0
      severity: high
```

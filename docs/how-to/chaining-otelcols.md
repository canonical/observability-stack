# Tier the OpenTelemetry Collector with different pipelines per data stream

The upstream OpenTelemetry Collector (otelcol) supports a wide range of [architectures](https://opentelemetry.io/docs/collector/architecture/). The [charmed version](https://charmhub.io/opentelemetry-collector-k8s) is opinionated and configures a receiver or exporter, depending on whether the juju relation sources or sinks telemetry, respectively. When multiple relations exist, all data goes from all receivers to all exporters. Since the charm manages the oltecol config file, only offering the [processors](https://charmhub.io/opentelemetry-collector-k8s/configurations?channel=2/edge#processors) config option to interface with it, a configuration limitation exists. This is solved by tiering otelcols in data streams which require unique processing.

## Tiering outgoing data streams
One imaginable scenario is splitting a log stream into [hot and cold data](https://en.wikipedia.org/wiki/Cold_data) based on log levels. The `batching` otelcol collects logs directly from `Flog` with a [batch processor](https://github.com/open-telemetry/opentelemetry-collector/blob/main/processor/batchprocessor/README.md) to improve the efficiency of both exported log streams via compression. Low-severity levels like `DEBUG` and `INFO` often have a greater frequency in log streams and indicate normal workload operation. This can be filtered out in a log stream which is sent to long-term (cold) storage to minimize cost while maintaining compliance. For compliance reasons we may also want to implement a [redaction processor](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/redactionprocessor/README.md) for removing sensitive production data. Alternatively, the hot storage could include `INFO` logs, since storage is less costly, while filtering out `DEBUG` logs.

To understand how to filter telemetry with otelcol, refer to the [selectively drop telemetry](selectively-drop-telemetry) documentation or see the [examples for log-level filtering](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/filterprocessor/testdata/config_logs_min_severity.yaml).

```{mermaid}
flowchart TB

flog[Flog] --> fan-out
fan-out["Otel-collector<br>(batching)"]
fan-out --> warn
fan-out --> info
warn["Otel-collector<br>(info filter)"] --> redact
redact["Otel-collector<br>(redaction)"] --> loki-cold
info["Otel-collector<br>(debug filter)"] --> loki-hot
loki-hot["Loki<br>(hot storage)"]
loki-cold["Loki<br>(cold storage)"]

class fan-out,redact,warn,info thickStroke;
classDef thickStroke stroke-width:2px, stroke:#FFA500;
```

### Hot storage processor config
```yaml
filter/include:
  logs:
    include:
      severity_number:
        min: "INFO"
        match_undefined: true
```

```{note}
This filters out all logs below "INFO" level (the whole DEBUG and TRACE ranges). Logs with no defined severity will also be matched.
```

### Cold storage processor config
```yaml
filter/include:
  logs:
    include:
      severity_number:
        min: "WARN"
        match_undefined: true
```

## Tiering incoming data streams
Another imaginable scenario is classifying log streams prior to ingestion in a common storage destination. Each `Flog` log source has unique downstream data processing, useful for environment classification and identification. Both datastream benefit from the `batching` otelcol. Additionally, both data streams have an [attributes processor](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/attributesprocessor/README.md), uniquely configured, to classify the logging source environment. Finally, only the production data stream uses the redaction processor for compliance reasons.

```{mermaid}
flowchart TB

flog-dev["Flog<br>(dev)"] --> dev-attr
dev-attr["Otel-collector<br>(prod attributes)"] --> fan-in

flog-prod["Flog<br>(prod)"] --> prod-attr
prod-attr["Otel-collector<br>(dev attributes)"] --> redact

fan-in["Otel-collector<br>(batching)"] --> loki[Loki]
redact["Otel-collector<br>(redaction)"] --> fan-in

class fan-in,redact,dev-attr,prod-attr thickStroke;
classDef thickStroke stroke-width:2px, stroke:#FFA500;
```

### Dev environment processor config
```yaml
attributes/insert:
  actions:
    - key: "region-a.environment"
      value: "dev"
      action: upsert
```

### Prod environment processor config
```yaml
attributes/upsert:
  actions:
    - key: "region-a.environment"
      value: "prod"
      action: upsert
```

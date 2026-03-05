# Tier OpenTelemetry Collector with different pipelines per data stream

By design, [charmed OpenTelemetry Collector](https://charmhub.io/opentelemetry-collector-k8s) (otelcol) forwards all receivers to all exporters.
For this reason, in order to mimic the wide range of [architectures](https://opentelemetry.io/docs/collector/architecture/) that the pipeline config supports,
multiple OpenTelemetry Collector charms may need to be deployed in a tiered topology.
One such use case is for processing data differently per receiver or exporter.

## Tiering outgoing data streams

One imaginable scenario is splitting a log stream into [hot and cold data](https://en.wikipedia.org/wiki/Cold_data) based on log levels. For compliance reasons we may also want to implement a [redaction processor](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/redactionprocessor/README.md) for removing sensitive data. Additionally, the [batch processor](https://github.com/open-telemetry/opentelemetry-collector/blob/main/processor/batchprocessor/README.md) improves efficiency of both log streams via compression. Low-severity levels like `TRACE`, `DEBUG` and `INFO` often have a greater frequency in log streams and indicate normal workload operation. This can be filtered out in a log stream which is sent to long-term (cold) storage to minimize cost while maintaining compliance. Conversely, the hot storage could include `INFO` logs, since storage is short-term, while still filtering out `TRACE` and `DEBUG` logs.

To understand how to filter telemetry with otelcol, refer to the [selectively drop telemetry](selectively-drop-telemetry) documentation or see the [examples for log-level filtering](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/filterprocessor/testdata/config_logs_min_severity.yaml).

```{mermaid}
flowchart TB

flog[flog] --> fan-out
fan-out["opentelemetry-collector<br>(redact & batch)"]
fan-out --> warn
fan-out --> info
warn["opentelemetry-collector<br>(cold filter)"] --> loki-cold
info["opentelemetry-collector<br>(hot filter)"] --> loki-hot
loki-hot["loki<br>(hot storage)"]
loki-cold["loki<br>(cold storage)"]

class fan-out,warn,info thickStroke;
classDef thickStroke stroke-width:2px, stroke:#FFA500;
```

With Juju config we use the [otelcol processor config](https://charmhub.io/opentelemetry-collector-k8s/configurations?channel=2/edge#processors) to:

1. Set the minimum severity level to `WARNING`

```{literalinclude} /how-to/tiered-outgoing-otelcol-bundle.yaml
:lines: 3, 10-18
```

2. Set the minimum severity level to `INFO`

```{literalinclude} /how-to/tiered-outgoing-otelcol-bundle.yaml
:lines: 32, 39-46
```

3. Redact sensitive log messages and batch

```{literalinclude} /how-to/tiered-outgoing-otelcol-bundle.yaml
:lines: 79, 86-91
```

## Tiering incoming data streams

Another imaginable scenario is classifying log streams prior to ingestion into a common storage destination. Each `flog` log source has unique downstream data processing, useful for environment classification and identification. Both data streams benefit from the `redact & batch` otelcol using the [redaction processor](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/redactionprocessor/README.md) for compliance reasons and the [batch processor](https://github.com/open-telemetry/opentelemetry-collector/blob/main/processor/batchprocessor/README.md) for efficiency. Additionally, they have an [attributes processor](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/attributesprocessor/README.md), uniquely configured, to classify the logging source environment.

```{mermaid}
flowchart TB

flog-dev["flog<br>(dev)"] --> dev
dev["opentelemetry-collector<br>(dev attributes)"] --> fan-in

flog-prod["flog<br>(prod)"] --> prod
prod["opentelemetry-collector<br>(prod attributes)"] --> fan-in

fan-in["opentelemetry-collector<br>(redact & batch)"] --> loki[loki]

class fan-in,dev,prod thickStroke;
classDef thickStroke stroke-width:2px, stroke:#FFA500;
```

With Juju config we use the [otelcol processor config](https://charmhub.io/opentelemetry-collector-k8s/configurations?channel=2/edge#processors) to:

1. Label the log stream as `development` and originating from `region-a`

```{literalinclude} /how-to/tiered-incoming-otelcol-bundle.yaml
:lines: 3, 10-16
```

2. Label the log stream as `production` and originating from `region-a`

```{literalinclude} /how-to/tiered-incoming-otelcol-bundle.yaml
:lines: 53, 60-66
```

3. Redact sensitive log messages and batch

```{literalinclude} /how-to/tiered-incoming-otelcol-bundle.yaml
:lines: 71, 78-84
```

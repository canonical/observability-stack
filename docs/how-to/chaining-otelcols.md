# Chaining OpenTelemetry Collectors for telemetry stream processing

The upstream OpenTelemetry Collector (otelcol) supports a wide range of [architectures](https://opentelemetry.io/docs/collector/architecture/). The [charmed version](https://charmhub.io/opentelemetry-collector-k8s) simplifies deployment and integration into various architectures, allowing administrators to configure multiple otelcol instances with specific microservice-like roles instead of relying on a single otelcol with numerous processors. This chaining approach clearly defines the responsibilities of each otelcol instance, making it easy to replace one without losing all processing at once.

One imaginable scenario is splitting a log stream into [hot and cold data](https://en.wikipedia.org/wiki/Cold_data) based on log levels. The first `Otel-collector` collecting logs directly from `Flog` has a [batch processor](https://github.com/open-telemetry/opentelemetry-collector/blob/main/processor/batchprocessor/README.md) to improve the efficiency of both log streams via compression. Low-severity levels like `DEBUG` and `INFO` often have a greater frequency in log streams and indicate normal workload operation. This can be filtered out in a log stream which is sent to long-term (cold) storage to minimize cost while maintaining compliance. Alternatively, the hot storage could include `INFO` logs, since storage is less costly, while filtering out `DEBUG` logs.

```{mermaid}
flowchart TB
flog[Flog] --> fan-out
fan-out["Otel-collector<br>(batch processing)"]
fan-out --> warn
fan-out --> info
warn["Otel-collector<br>(info-filter)"] --> loki-cold
info["Otel-collector<br>(debug-filter)"] --> loki-hot
loki-hot["Loki<br>(hot storage)"]
loki-cold["Loki<br>(cold storage)"]
```

To understand how to filter telemetry with otelcol, refer to the [selectively drop telemetry](https://discourse.charmhub.io/t/selectively-drop-telemetry/18377) documentation or see the [examples for log-level filtering](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/filterprocessor/testdata/config_logs_min_severity.yaml).

## Hot storage processor config
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

## Cold storage processor config
```yaml
filter/include:
  logs:
    include:
      severity_number:
        min: "WARN"
        match_undefined: true
```
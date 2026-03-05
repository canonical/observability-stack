# Selectively drop telemetry using opentelemetry-collector

Sometimes, from a resource perspective, applications are instrumented with more telemetry than we want to afford. In such cases, we can choose to selectively drop some before they are ingested.

## Filter processor

The [charmed OpenTelemetry Collector](https://charmhub.io/opentelemetry-collector-k8s) (otelcol) is ideal for dropping telemetry due to its processing abilities. Its telemetry format is defined by the OpenTelemetry Protocol (OTLP) with [example JSON files for all signals](https://github.com/open-telemetry/opentelemetry-proto/blob/main/examples/README.md). In OTLP, data is organized hierarchically:

```
LogsData -> ResourceLogs -> ScopeLogs -> LogRecord
MetricsData -> ResourceMetrics -> ScopeMetrics -> Metric
TracesData -> ResourceSpans -> ScopeSpans -> Span
```

Generally speaking, `Data` is a collection of `Resource` items associated with specific resources such as a specific service or host.  Each `Resource` contains information about itself and multiple `Scope` items, for grouping based on their `InstrumentationScope` (the library or component responsible for generating the telemetry). The `LogRecord`, `Metric`, and `Span` are the core building blocks of the respective telemetry that represents a single operation or activity.

Using the [debug exporter with normal verbosity](https://github.com/open-telemetry/opentelemetry-collector/tree/main/exporter/debugexporter#normal-verbosity), enabled per telemetry type, we can inspect the signals which make it through the pipeline.

```yaml
exporters:
  debug:
    verbosity: normal
service:
  pipelines:
    logs:
      exporters:
        - debug
    metrics:
      exporters:
        - debug
    traces:
      exporters:
        - debug
```

This allows us to understand the structure of the signal's resources and attributes prior to crafting our filtering. You can check the charm's debug exporter output with the command: `juju ssh --container otelcol OTELCOL_APP/0 "pebble logs -f"`. 

### Understanding processors

Before reaching an exporter, a signal is first processed by a processor and any modification to signals are propagated throughout the remainder of the pipeline. The [filter](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/processor/filterprocessor/README.md) processor supports the [OpenTelemetry Transformation Language (OTTL)](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/pkg/ottl/README.md). This allows us to  define:

1. A function that transforms (or drops) telemetry
2. Optionally, a condition that determines whether the function is executed.

Be aware of the **Warnings** section of the filter processor:
- [filterprocessor#warnings](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/filterprocessor#warnings)

Incorrectly modifying or dropping telemetry can result in data loss!

To gain insight on how effective the filter processor is, curl the metrics endpoint for the `otelcol_processor_filter_datapoints_filtered` metric with:

```shell
juju ssh --container otelcol opentelemetry-collector/0 "curl http://localhost:8888/metrics" | grep otelcol_processor_filter_datapoints_filtered
```

### Drop metrics

By default, otelcol self-scrapes its metrics and sends it into the configured pipeline, which is useful for operational diagnostics. In some use cases, this self-scraping telemetry is not desired and can be dropped.

A metric signal flowing through the pipeline will look similar to:

```shell
ResourceMetrics #0 service.name=otelcol server.address=how-to_7b30903e_otelcol_otelcol/0 service.instance.id=299818a5-2dab-43e2-a6a5-015bab12cc75 server.port= url.scheme=http juju_application=otelcol juju_charm=opentelemetry-collector-k8s juju_model=how-to juju_model_uuid=7b30903e-8941-4a40-864c-0cbbf277c57f juju_unit=otelcol/0 service.version=0.130.1
ScopeMetrics #0 github.com/open-telemetry/opentelemetry-collector-contrib/receiver/prometheusreceiver@0.130.1
scrape_samples_post_metric_relabeling{juju_application=otelcol,juju_charm=opentelemetry-collector-k8s,juju_model=how-to,juju_model_uuid=7b30903e-8941-4a40-864c-0cbbf277c57f,juju_unit=otelcol/0} 17
```

```yaml
processors:
  filter/exclude:
      metrics:
        exclude:
          match_type: regexp
          metric_names:
            - "scrape_samples_.+"
```

Alternatively, you can use an OTTL expression for the entire `otelcol` service:

```yaml
processors:
  filter/exclude:
    metrics:
      datapoint:
          - 'resource.attributes["service.name"] == "otelcol"'
```

### Drop logs

The log bodies may contain successful (`2xx`) status codes. In some use cases, this telemetry is not desired and can be dropped using the filter processor.

A log signal flowing through the pipeline will look similar to:

```shell
ResourceLog #0 loki.format=raw
ScopeLog #0
{"level":"WARNING", "host":"161.168.71.228", "user-identifier":"-", "datetime":"19/Aug/2025:15:33:08 +0000", "method": "PATCH", "request": "/portals/utilize", "protocol":"HTTP/1.1", "status":205, "bytes":9281, "referer": "http://www.leadportals.info/extensible/world-class/supply-chains", "message": "molestias et impedit ... fugiat error di"} job=juju_test-1-1_5599bed2_flog juju_application=flog juju_charm=flog-k8s juju_model=test-1-1 juju_model_uuid=5599bed2-5711-4573-8dbd-95f76fa60f3e juju_unit=flog/0 container=workload filename=/bin/fake.log loki.attribute.labels=container, job, filename, juju_application, juju_charm, juju_model, juju_model_uuid, juju_unit, snap_name, path
```

**Note**: the log body is enclosed in curly braces.

```yaml
processors:
  filter/exclude:
    logs:
      exclude:
        match_type: regexp
        bodies:
          - '"status":2[0-9]{2}'
```

### Drop traces

When an application is scaled, we receive traces for multiple units. In some use cases, this telemetry is not desired and can be dropped using the filter processor.

A trace signal flowing through the pipeline will look similar to:

```shell
ResourceTraces #0 juju_application=graf juju_charm=grafana-k8s juju_model=how-to juju_model_uuid=7b30903e-8941-4a40-864c-0cbbf277c57f juju_unit=graf/1 process.runtime.description=go version go1.19.13 linux/amd64 service.name=grafana service.version=3.5.5 telemetry.sdk.language=go telemetry.sdk.name=opentelemetry telemetry.sdk.version=1.14.0
ScopeTraces #0 component-main
open session c13051073ab5a5b1a158008cc460eb5d 8519ed6a8feb05c0 transaction=true
     {"resource": {"service.instance.id": "3e0e472b-2c94-4a2e-836a-56d110d2cc66", "service.name": "otelcol", "service.version": "0.130.1"}, "otelcol.component.id": "debug", "otelcol.component.kind": "exporter", "otelcol.signal": "traces"}
2025-08-11T08:25:22.183Z     debug   sampling/status_code.go:54      Evaluating spans in status code filter      {"resource": {"service.instance.id": "3e0e472b-2c94-4a2e-836a-56d110d2cc66", "service.name": "otelcol", "service.version": "0.130.1"}, "otelcol.component.id": "tail_sampling", "otelcol.component.kind": "processor", "otelcol.pipeline.id": "traces", "otelcol.signal": "traces", "policy": "status_code"}
2025-08-11T08:25:22.183Z     debug   sampling/string_tag_filter.go:95        Evaluating spans in string-tag filter       {"resource": {"service.instance.id": "3e0e472b-2c94-4a2e-836a-56d110d2cc66", "service.name": "otelcol", "service.version": "0.130.1"}, "otelcol.component.id": "tail_sampling", "otelcol.component.kind": "processor", "otelcol.pipeline.id": "traces", "otelcol.signal": "traces", "policy": "string_attribute"}
2025-08-11T08:25:22.183Z     debug   sampling/probabilistic.go:46    Evaluating spans in probabilistic filter    {"resource": {"service.instance.id": "3e0e472b-2c94-4a2e-836a-56d110d2cc66", "service.name": "otelcol", "service.version": "0.130.1"}, "otelcol.component.id": "tail_sampling", "otelcol.component.kind": "processor", "otelcol.pipeline.id": "traces", "otelcol.signal": "traces", "policy": "probabilistic"}
```

```yaml
processors:
  filter/exclude:
    traces:
      span:
        - IsMatch(resource.attributes["juju_unit"], "graf/0")
```

## References

- Official docs: [collector configuration](https://opentelemetry.io/docs/collector/configuration/)
- The [OTLP data model](https://betterstack.com/community/guides/observability/otlp/#the-otlp-data-model)

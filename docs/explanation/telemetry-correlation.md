```markdown
# Telemetry correlation: traces, metrics and logs

This explanation describes what telemetry correlation is, why it matters, and how the COS stack and associated charms enable and use correlation between traces, metrics and logs. It synthesises guidance from the Tempo HA charm documentation and provides concise examples for common components (OpenTelemetry Collector, Fluent Bit, Prometheus/Mimir exemplars).

## What is telemetry correlation?

Telemetry correlation is the practice of linking related telemetry items across signals — for example, connecting a trace (a distributed request) with log events and metric samples that occurred while handling that request. Correlation typically uses identifiers such as a trace id (and optionally span id) attached to logs and exemplars so UIs and backends can surface related events.

Common correlation types:

- **Traces -> Logs**: include the trace id/span id in application logs so a log viewer (e.g. Grafana's log view) can link to the trace in Tempo.
- **Traces -> Metrics**: attach trace information as Prometheus exemplars to time series samples so metrics can be linked to traces.

## Why correlation matters

- Faster debugging: find the trace that caused an alerting metric spike or locate related logs for a failing request.
- Richer observability: connect high-level symptoms (metrics) to request level diagnostics (traces) and textual context (logs).
- Improved incident response: pivot between signals quickly without hunting for matching timestamps.

## How COS enables correlation

The COS Terraform module automatically enables telemetry correlation. This means the stack is configured to accept and surface correlation data (for example, Tempo and Loki are installed and reachable, and Mimir/Prometheus is configured to support exemplars). The following sections explain the pieces you still need to configure in your instrumented applications and agents to actually emit correlated telemetry.

Important: COS enables the backends and integrations that make correlation possible. Application-level instrumentation (or agents) must still include trace context in logs and emit exemplars for metrics.

## How to enable traces -> logs correlation

Goal: ensure log records include trace context (trace id and span id) and that the log pipeline preserves them.

1) Application instrumentation

- Use an OpenTelemetry logging integration (language-specific) or ensure your logging formatter injects the `trace_id`/`span_id` into every log record when a current span exists.
- For many frameworks, this is an option in the logging library or OTEL auto-instrumentation. Example keys often used: `trace_id`, `span_id`, or `traceparent` header value.

2) Collector / Agent / Fluent Bit

- If using Fluent Bit to forward logs, configure it to preserve the fields and pass them through to Loki. If your application writes the W3C `traceparent` header into a log field, forward it as-is, or parse it into `trace_id` and `span_id` fields.

Fluent Bit example (pseudo-config):

```yaml
# parse or preserve `traceparent` field and send to Loki
[FILTER]
    Name    modify
    Match   *
    Add     traceparent ${traceparent}

[OUTPUT]
    Name  loki
    Match *
    Host  <loki-host>
    Port  3100
```

3) Loki UI

- Loki can be configured to surface links to Tempo when logs carry a trace id. COS's deployment wiring (via charms/relations) will make these endpoints available.

## How to enable traces -> metrics correlation (exemplars)

Goal: attach exemplars (trace ids) to Prometheus samples so metrics UIs can open the corresponding trace.

1) Client libraries

- Use a Prometheus client that supports exemplars or an OpenTelemetry metrics exporter that emits exemplars. When recording a sample that should be correlated, attach the active span's trace id as an exemplar.

2) Scraping / pushing

- If using push-based exporters (Grafana Agent, OTel Collector -> Mimir), ensure the pipeline preserves exemplars.

Example (pseudo-code):

```text
# when recording a histogram/summary, add exemplar with trace_id
my_histogram.observe(value, exemplar={"trace_id": current_span.trace_id})
```

3) Backend support

- Mimir (and newer Prometheus versions) support exemplars and can display trace links; COS config (post-#119) ensures Mimir is available and linked.

## Example OpenTelemetry Collector pipeline (concept)

This is a conceptual example showing the collector receiving traces, metrics and logs and ensuring correlation fields are present when exporting.

```yaml
receivers:
  otlp:
    protocols:
      http: {}

processors:
  batch: {}

exporters:
  otlp/tempo:
    endpoint: <tempo-endpoint>:4317
  prometheusremotewrite/mimir:
    endpoint: <mimir-rw-endpoint>
  loki:
    endpoint: <loki-endpoint>

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp/tempo]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheusremotewrite/mimir]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [loki]
```

Tips:

- Ensure your application or sidecar injects trace context into logs (or use the collector's log processor to attach context when possible).
- For exemplars, prefer instrumenting at the application or agent level rather than trying to synthesize trace ids later.

## Verification and troubleshooting

- Verify traces: use Grafana's Explore tab with Tempo datasource to confirm traces arrive and contain expected trace ids.
- Verify logs: check a log entry in Loki's API or Grafana Explore tab; confirm it contains `trace_id`/`traceparent` fields and that the UI links to Tempo.
- Verify exemplars: in Grafana/Mimir, view the metric sample and check for exemplar data. Prometheus's `exemplars` API can also be used to inspect them.

Common problems

- Missing fields: ensure your instrumentation writes the trace context into logs and that any log processors do not drop those fields.
- Missing exemplars: not all client libraries attach exemplars by default; check your instrumentation's docs and the agent/exporter configuration.
- Time/label mismatch: exemplars require the correct metric and label set to be applied; double-check the metric name and labels.

## Practical notes for COS users

- COS's Terraform changes in #119 configure the backend services to accept and surface correlations, but you still need to enable or ensure instrumentation and agent configurations emit the context.
- For Kubernetes deployments, prefer in-pod instrumentation (or sidecar agents) to preserve full trace context.

## References

- Tempo HA docs — Correlating traces, metrics, logs (charm docs)
- Tempo HA docs — How to enable correlation from traces to logs (charm docs)
- Tempo HA docs — How to enable correlation from traces to metrics (charm docs)

For details and the original charm-level instructions, see the Tempo HA charm documentation pages on CharmHub.

```

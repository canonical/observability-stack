# Telemetry correlation: traces, metrics and logs

This explanation describes what telemetry correlation is, why it matters, and how the COS stack and associated charms enable and use correlation between traces, metrics and logs. It provides examples for common components (OpenTelemetry Collector, Prometheus/Mimir exemplars).

## What is telemetry correlation?

Telemetry correlation is the practice of linking related telemetry items across signals — for example, connecting a trace (a distributed request) with log events and metric samples that occurred while handling that request. Correlation typically uses identifiers such as a trace id (and optionally span id) attached to logs and [exemplars](https://grafana.com/docs/grafana/latest/fundamentals/exemplars/) so UIs and backends can surface related events.

Common correlation types:

- **Traces -> Logs**: include the trace id/span id in application logs so a log viewer (e.g. Grafana's log view) can link to the trace in Tempo.
- **Traces -> Metrics**: attach trace information as Prometheus exemplars to time series samples so metrics can be linked to traces.

## Why correlation matters

- **Faster debugging**: find the trace that caused an alerting metric spike or locate related logs for a failing request.
- **Richer observability**: connect high-level symptoms (metrics) to request level diagnostics (traces) and textual context (logs).
- **Improved incident response**: pivot between signals quickly without hunting for matching timestamps.

## How COS enables correlation

The COS Terraform module automatically enables telemetry correlation. This means the stack is configured to accept and surface correlation data (for example, Tempo and Loki are installed and reachable, and Mimir is configured to support exemplars). The following sections explain the pieces you still need to configure in your instrumented applications and agents to actually emit correlated telemetry.

Important: COS enables the backends and integrations that make correlation possible. Application-level instrumentation (or agents) must still include trace context in logs and emit exemplars for metrics.

## How to enable traces -> logs correlation

Goal: ensure log records include trace context (trace id and span id) and that the log pipeline preserves them.

### Your application

Use an OpenTelemetry logging integration (language-specific) or ensure your logging formatter injects the `trace_id`/`span_id` into every log record when a current span exists.

For many frameworks, this is an option in the logging library or OTEL auto-instrumentation. Example keys often used: `trace_id`, `span_id`, or `traceparent` header value.

### Canonical Observability Stack

When you deploy COS using its terraform module, you’ll automatically get all the required integrations needed to enable trace-to-logs correlation.

If you manually created the terraform module or deployed COS without using it, you should be able to enable the feature by running a single command:

```text
juju integrate tempo:receive-datasource loki
```

> See more: [Tempo HA docs - How to enable correlation from traces to logs](https://discourse.charmhub.io/t/tempo-ha-docs-how-to-enable-correlation-from-traces-to-logs/19029)

## How to enable traces -> metrics correlation (exemplars)

When you deploy COS using its terraform module, you’ll automatically get all the required integrations needed to enable trace-to-logs correlation.

If you manually created the terraform module or deployed COS without using it, you should be able to enable the feature by running a single command:

```text
juju integrate tempo:receive-datasource mimir
```

> See more: [Tempo HA docs - How to enable correlation from traces to metrics](https://discourse.charmhub.io/t/tempo-ha-docs-how-to-enable-correlation-from-traces-to-metrics/19094)

### Client libraries

Use a Prometheus client that supports exemplars or an OpenTelemetry metrics exporter that emits exemplars. When recording a sample that should be correlated, attach the active span's trace id as an exemplar.

### Backend support

Mimir supports exemplars and trace links can be displayed in Grafana; COS Terraform module (post-[#119](https://github.com/canonical/observability-stack/pull/119)) ensures Mimir is available and integrated to support the correlation.


## Verification and troubleshooting

- Verify traces: use Grafana's Explore tab with Tempo datasource to confirm traces arrive and contain expected trace ids.
- Verify logs: check a log entry in Loki's API or Grafana Explore tab; confirm it contains `trace_id`/`traceparent` fields and that the UI links to Tempo.
- Verify exemplars: in Grafana/Mimir, view the metric sample and check for exemplar data. Prometheus's `exemplars` API can also be used to inspect them.

Common problems

- Missing fields: ensure your instrumentation writes the trace context into logs and that any log processors do not drop those fields.
- Missing exemplars: not all client libraries attach exemplars by default; check your instrumentation's docs and the agent/exporter configuration.

## Practical notes for COS users

- COS's Terraform changes in [#119](https://github.com/canonical/observability-stack/pull/119) configure the backend services to accept and surface correlations, but you still need to enable or ensure instrumentation and agent configurations emit the context.
- For Kubernetes deployments, prefer in-pod instrumentation (or sidecar agents) to preserve full trace context.

## References

- [Tempo HA docs — Correlating traces, metrics, logs](https://discourse.charmhub.io/t/tempo-ha-docs-explanation-correlating-traces-metrics-logs/16116)
- [Tempo HA docs — How to enable correlation from traces to logs](https://discourse.charmhub.io/t/tempo-ha-docs-how-to-enable-correlation-from-traces-to-logs/19029)
- [Tempo HA docs — How to enable correlation from traces to metrics](https://discourse.charmhub.io/t/tempo-ha-docs-how-to-enable-correlation-from-traces-to-metrics/19094)

For details and the original charm-level instructions, see the [Tempo HA charm documentation pages on CharmHub](https://discourse.charmhub.io/t/charmed-tempo-ha/15531).


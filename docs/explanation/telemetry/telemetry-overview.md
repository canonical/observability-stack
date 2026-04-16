---
myst:
  html_meta:
    description: "A short overview of how COS handles telemetry — collection, labeling, and correlation of logs, metrics, and traces."
---

(telemetry-overview)=

# Telemetry overview

Modern distributed systems generate three complementary signal types — **metrics**,
**logs**, and **traces** — each answering a different question:

| Signal  | Question it answers             | Example                                    |
|---------|---------------------------------|--------------------------------------------|
| Metrics | *How is the system behaving?*   | CPU usage, request latency percentiles      |
| Logs    | *What happened?*                | An error message with a stack trace         |
| Traces  | *Where did the time go?*        | A request's journey across seven services   |

COS collects all three and ties them together so you can jump from a
spike on a dashboard straight to the log line or trace that explains it.

## Collection

Signals reach COS through two paths:

- **Pull** — Prometheus (or Mimir) receive metrics from endpoints that charms
  expose automatically via `juju relate`.
- **Push** — Logs and traces are forwarded to Loki and Tempo, typically through
  an OpenTelemetry (OTel) Collector that charms configure for you.

In both cases the transport is set up by a Juju relation; no manual endpoint
configuration is required.

See {ref}`telemetry-collection` for the full picture.

## Labels

Every signal carries **labels** — key-value pairs such as
`juju_model`, `juju_application`, and `juju_unit` — that identify
*where* it came from.  Charm libraries inject these labels automatically,
giving you a consistent lens to filter and group telemetry across the
entire estate.

For OTLP-based workloads the same Juju topology is mapped to
OTel resource attributes, so push-based and pull-based data share an
identical naming scheme.

See {ref}`telemetry-labels` and {ref}`telemetry-otlp-topology-labels` for details.

## Correlation

Labels alone let you filter; **correlation** lets you navigate.  COS links
signals together in two ways:

- **Trace → Log** — trace and span IDs embedded in log records let Grafana
  jump from a slow trace to the exact log lines it produced.
- **Trace → Metric** — Prometheus exemplars attach trace IDs to metric
  samples, connecting a latency spike to the trace that caused it.

The backend integrations (Tempo ↔ Loki, Tempo ↔ Mimir) are enabled by
default in the COS Terraform modules; you only need to ensure your
applications emit the right context.

See {ref}`telemetry-correlation` for a deeper dive.

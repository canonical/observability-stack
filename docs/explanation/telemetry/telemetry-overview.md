---
myst:
  html_meta:
    description: "A short overview of how COS handles telemetry — collection, labeling, and correlation of logs, metrics, and traces."
---

# Telemetry overview

Modern distributed systems generate three complementary telemetry types, **metrics**,
**logs**, and **traces**, each provide a different view of the system:

| Telemetry type | Purpose                              | Example                                        |
|----------------|--------------------------------------|------------------------------------------------|
| Metrics        | Quantify system state                | CPU usage, request latency percentiles         |
| Logs           | Record events                        | An error message with a stack trace            |
| Traces         | Data flow and timing across services | A request's journey across different services  |

COS collects all three types and stores them in separate backends. When telemetries share identifiers (such as labels or trace IDs), they can be correlated across systems. For example, linking a metric spike to the logs or traces associated with the same request.

## Collection

Telemetry reaches COS through two paths:

- **Pull**. Prometheus (or Mimir) receives metrics from endpoints that charms
  expose automatically via `juju relate`.
- **Push**. Logs and traces are forwarded to Loki and Tempo, typically through
  an OpenTelemetry (OTel) Collector that charms configure for you.

In both cases the transport is set up by a Juju relation; no manual endpoint
configuration is required.

See [telemetry collection](telemetry-collection) for more information.

## Labels

Every telemetry type carries labels, which are key-value pairs that identify where the signal came from. Examples of labels used by COS include: 
- `juju_model`
- `juju_application`
- `juju_unit`
These labels are added by charm libraries and provide a consistent way to filter and group data across your entire estate.

For OTLP-based workloads, the same Juju topology is mapped to OTel resource attributes, so push-based and pull-based data share an identical naming scheme. This allows metrics, logs, and traces to be queried using the same identifiers, regardless of how they were collected.

See [telemetry labels](telemetry-labels) and [OTLP labels](telemetry-otlp-topology-labels) for details.

## Correlation

Correlation lets you navigate based on shared identifiers between signals. COS links
signals together in two ways:

- **Trace to Log**. Trace and span IDs embedded in log records let Grafana
  jump from a slow trace to the exact log lines it produced.
- **Trace to Metric**. Prometheus exemplars attach trace IDs to metric
  samples, connecting a latency spike to the trace that caused it.

The backend integrations (Tempo ↔ Loki, Tempo ↔ Mimir) are enabled by
default in the COS Terraform module; you only need to ensure your
applications emit the right context.

See [telemetry correlation](telemetry-correlation) for more information.

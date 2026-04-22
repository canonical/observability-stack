---
myst:
  html_meta:
    description: "Deep dives into how logs, metrics, and traces are collected, labelled, and correlated across the COS stack."
---

(telemetry)=

# Telemetry

These pages describe how each telemetry type (logs, metrics, traces) is
collected, labeled, and correlated across the stack.

```{toctree}
:maxdepth: 1

Overview <telemetry-overview>
```

## Collection & labeling

How each signal type is collected and consistently labeled across the stack.

```{toctree}
:maxdepth: 1

Logging architecture <logging-architecture>
Telemetry labels <telemetry-labels>
Telemetry collection <telemetry-collection>
```

## Correlation & interoperability

How COS maps OpenTelemetry Protocol (OTLP) conventions to Juju topology and correlates
telemetry for unified insight.

```{toctree}
:maxdepth: 1

OpenTelemetry Protocol (OTLP) Juju topology labels <telemetry-otlp-topology-labels>
Telemetry correlation <telemetry-correlation>
```

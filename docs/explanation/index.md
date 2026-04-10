---
myst:
  html_meta:
    description: "Understand COS architecture and design decisions, telemetry models, Juju topology, stack variants, and alerting."
---

(explanation)=

# Explanation

These pages provide conceptual background and design intent for the COS
stack. Use this section to understand the why and how behind
our architecture, telemetry model, and operational choices.

## Overview

A high-level introduction to observability and the model-driven approach COS makes
use of.

```{toctree}
:maxdepth: 1

About COS index <about-cos/index>
What is Observability? <https://canonical.com/observability/what-is-observability>
Model-Driven Observability <https://ubuntu.com/blog/tag/model-driven-observability>
What is COS? <about-cos/what-is-cos>
```

## Topology & stack variants

Information about deployment topology, the Juju model layout, and the
different stack variants available (COS, and COS Lite).

```{toctree}
:maxdepth: 1

Juju Topology <about-cos/juju-topology>
Stack variants <about-cos/stack-variants>
```

## Architecture & design

These pages describe the architecture decisions, design goals, and the
telemetry pipelines we rely on. They are useful when evaluating how COS fits
into your observability strategy or when designing integrations.

```{toctree}
:maxdepth: 1

Design Goals <about-cos/design-goals>
Logging Architecture <integrations/logging-architecture>
Telemetry Flow <about-cos/telemetry-flow>
Telemetry Correlation <integrations/telemetry-correlation>
Telemetry Labels <about-cos/telemetry-labels>
Opentelemetry Protocol (OTLP) Juju Topology Labels <about-cos/telemetry-otlp-topology-labels>
Data Integrity <operations/data-integrity>
```

## Alerting & rules

Guidance about built-in alerting, charmed alert rules and how rules are
designed and managed across the stack.

```{toctree}
:maxdepth: 1

Charmed alert rules <integrations/charmed-rules>
Generic alert rules <integrations/generic-rules>
Dashboard upgrades and deduplication <operations/dashboard-upgrades>
```

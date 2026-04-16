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

## Getting started with COS concepts

Start here to understand what observability is, the model-driven approach COS
follows, and what COS is.

```{toctree}
:maxdepth: 1

Overview <overview/index>
```

## Architecture & design

Understand the structural decisions, deployment topology, and stack variants
that shape COS.

```{toctree}
:maxdepth: 1

Architecture & topology <architecture/index>
```

## Signal pipeline

Learn how logs, metrics, and traces flow through the stack, and how alerting
and dashboards surface insights from that telemetry.

```{toctree}
:maxdepth: 1

Telemetry <telemetry/index>
Alerting & dashboards <alerting/index>
```

## Day-2 operations

Explore operational concerns such as data integrity, retention, and upgrade
handling.

```{toctree}
:maxdepth: 1

Operations & data <operations/index>
```

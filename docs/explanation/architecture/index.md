---
myst:
  html_meta:
    description: "COS architecture, deployment topology, Juju model layout, stack variants, and telemetry pipelines."
---

(architecture)=

# Architecture & topology

Information about COS architecture, deployment topology, the Juju model
layout, and the different stack variants available.

## Design philosophy

The guiding principles and goals behind the COS architecture.

```{toctree}
:maxdepth: 1

Design Goals <design-goals>
```

## Topology & models

How COS organizes charms, relations, and models within the Juju ecosystem.

```{toctree}
:maxdepth: 1

Juju Topology <juju-topology>
Juju Topology Labels <juju-topology-labels>
Model Topology for COS Lite <cos-lite-model-topology>
```

## Stack shape & data flow

The available stack configurations and how telemetry moves through them.

```{toctree}
:maxdepth: 1

Stack variants <stack-variants>
Telemetry Flow <telemetry-flow>
```

.. _explanation:

Explanation
***********

These pages provide conceptual background and design intent for the COS
stack. Use this section to understand the why and how behind
our architecture, telemetry model, and operational choices.

Overview
========

A high-level introduction to observability and the model-driven approach COS makes
use of.

.. toctree::
   :maxdepth: 1

   What is Observability? <https://canonical.com/observability/what-is-observability>
   Model-Driven Observability <https://ubuntu.com/blog/tag/model-driven-observability>

Topology & stack variants
=========================

Information about deployment topology, the Juju model layout, and the
different stack variants available (COS, and COS Lite).

.. toctree::
   :maxdepth: 1

   Juju Topology <juju-topology>
   Stack variants <stack-variants>

Architecture & design
=====================

These pages describe the architecture decisions, design goals, and the
telemetry pipelines we rely on. They are useful when evaluating how COS fits
into your observability strategy or when designing integrations.

.. toctree::
   :maxdepth: 1

   Design Goals <design-goals>
   Logging Architecture <logging-architecture>
   Telemetry Flow <telemetry-flow>
   Telemetry correlation <telemetry-correlation>
   Telemetry Labels <telemetry-labels>
   Data Integrity <data-integrity>

Alerting & rules
=================

Guidance about built-in alerting, charmed alert rules and how rules are
designed and managed across the stack.

.. toctree::
   :maxdepth: 1

   Charmed alert rules <charmed-rules>
   Generic alert rules <generic-rules>
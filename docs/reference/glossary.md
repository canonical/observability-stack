---
myst:
 html_meta:
  description: "COS glossary: concise definitions of terms and concepts unique to the Canonical Observability Stack."
---

# Glossary

Terms and concepts specific to COS.

## Catalogue

The [Catalogue charm](https://charmhub.io/catalogue-k8s) provides a service-discovery
landing page for COS, listing integrated applications and their ingress URLs. Deployed
as a core component of both COS and COS Lite.

## Charmed alert rules

Alert rules bundled inside a charmed operator and automatically forwarded to Prometheus or
Loki when the charm is related to COS. Rule expressions are injected with Juju topology 
matchers at relation time, identifying them with that application's telemetry.
See [Charmed alert rules](/explanation/alerting/charmed-rules).

## COS (Canonical Observability Stack)

The full, horizontally-scalable, Kubernetes-native observability suite. Backends (Mimir,
Loki, Tempo) use the coordinator/worker pattern. Informally called **COS HA**.
See [What is COS?](/explanation/overview/what-is-cos).

## COS Alerter

A dedicated Alertmanager instance deployed **outside** the COS model to receive a
heartbeat alert from COS. Fires when the heartbeat stops, signalling that COS's own
alerting pipeline has failed. See [Topology](/reference/topology).

## COS Configuration

A [peripheral charm](#peripheral-charm) that clones a git repository (via a `git-sync`
workload) and provisions alert rules, dashboards, and scrape targets from it into COS.
Enables git-ops–style configuration independently of any charmed operator.
See [COS components](/reference/cos-components).

## COS Lite

A less resource-intensive flavour of COS that runs monolithic Loki and
Prometheus, without Tempo. Recommended for near-edge and single-node deployments.
See [What is COS?](/explanation/overview/what-is-cos).

## COS Proxy

A peripheral machine charm that bridges NRPE-instrumented workloads
to COS by translating their checks into Prometheus time series. A bridge for
legacy machine charms that do not yet expose metrics directly.
See [Telemetry flow](/explanation/architecture/telemetry-flow).

## `cos_agent`

An all-in-one Juju relation library used by machine charms to ship metrics, logs,
dashboards, and alert rules to COS through a subordinate Grafana Agent or OpenTelemetry
Collector. Replaces wiring up separate `prometheus_scrape`, `loki_push_api`, and
`grafana_dashboard` relations individually in machine contexts.
See [Integration matrix](/reference/integration-matrix).

## Coordinator/worker pattern

The deployment pattern used by COS backends (Mimir, Loki, Tempo): each backend is split
into a **coordinator charm** + one or more **worker charms**, each assigned a specific
role (e.g. `ingester`, `querier`, `compactor`). Enables independent scaling and
pod anti-affinity across nodes. COS Lite uses a monolithic charm instead.
See [What is COS?](/explanation/overview/what-is-cos).

## Cross-model relation (CMR)

A Juju relation that spans two separate models. Because COS is deployed in its own model,
CMRs are the primary mechanism by which workloads in other models — including machine
models — send telemetry to COS.

## Flavour

Informal term for the two COS deployment variants: **COS** (scalable, HA) and
**COS Lite** (monolithic, resource-constrained). Both share Grafana, Alertmanager,
Traefik, and Catalogue. See [What is COS?](/explanation/overview/what-is-cos).

## Generic alert rules

A minimal set of host-health rules shipped with COS itself, covering unreachable scrape
targets, missing metrics, and COS self-health. Relieve charm authors from implementing
per-charm host-health alerts. See [Generic alert rule groups](/explanation/alerting/generic-rules).

## Git-ops alert rules

Alert rules (and dashboards or scrape targets) loaded from an external git repository via
the [COS Configuration](#cos-configuration) charm. Allows version-controlled,
operator-defined rules outside of any charmed operator.

## Juju topology labels

The set of metadata — model name, model UUID, application, unit, charm name — that
uniquely identifies the source workload of a telemetry signal within a Juju-managed deployment.
Automatically associated with all telemetry by COS charm libraries.

Enables filtering and correlating telemetry by
model or application without manual instrumentation.

See [Juju topology](/explanation/architecture/juju-topology) and
[Juju topology labels](/explanation/architecture/juju-topology-labels).

## LMA (Logging, Monitoring and Alerting)

The machine-charm–based observability predecessor to COS. COS was designed to address
LMA's operational and architectural limitations: it is Kubernetes-native, Juju-topology-aware,
and relation-driven. See [Design goals](/explanation/architecture/design-goals).

## Pebble log forwarding

A mechanism by which Kubernetes charm workloads stream logs from their Pebble-managed
processes directly to a Loki push endpoint, without a sidecar scraping agent.
See [Telemetry collection](/explanation/telemetry/telemetry-collection).

## Peripheral charm

A charm that integrates with COS but is not part of its core stack — e.g. COS
Configuration, COS Proxy, Blackbox Exporter, Prometheus Scrape Config.
See [COS components](/reference/cos-components).

## Remote-write

The push-based protocol by which metrics are sent from an OpenTelemetry Collector or
Grafana Agent to Mimir or Prometheus (`prometheus_remote_write` relation/interface).
The primary delivery path for metrics from machine workloads and OTel pipelines in COS.
See [Telemetry collection](/explanation/telemetry/telemetry-collection).

## Rock

A Canonical OCI container image built with [`rockcraft`](https://documentation.ubuntu.com/rockcraft/en/latest/),
used as the workload image for COS charms. Published under the `ubuntu/` prefix.
See [COS components](/reference/cos-components).

## Scrape job

A named configuration block telling Prometheus or OpenTelemetry Collector which target to
poll, at what interval, and which labels to attach. COS charm libraries generate and manage
scrape jobs automatically when charms relate over `prometheus_scrape`, injecting
[Juju topology labels](#juju-topology-labels).
See [Telemetry labels](/explanation/telemetry/telemetry-labels).

## Self-monitoring

The capability of COS to observe its own components using the same stack it operates.
See [What is COS?](/explanation/overview/what-is-cos).

## Substrate

The environment type a charm targets: `k8s` (Kubernetes) or `machine` (bare-metal/VM).
Integration patterns and available [peripheral charms](#peripheral-charm) differ by
substrate. See [Integration matrix](/reference/integration-matrix).

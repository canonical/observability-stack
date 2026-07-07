---
myst:
 html_meta:
  description: "Architecture of the coordinated-workers pattern used in COS HA for Loki, Mimir, and Tempo: how it works, its components, and why it was chosen."
---

# Coordinated workers

In COS HA, Mimir, Loki, and Tempo are deployed as multiple Juju applications instead of single monolithic applications. Each backend has a coordinator application and one or more worker applications. The coordinator handles integrations, configurations, and routes traffic, while workers run the backend services needed for ingestion, querying, storage, and background processing.

This guide explains the coordinator-worker pattern in COS HA.

## Overview

The telemetry backend components in the COS stack (namely Loki, Mimir, and Tempo) are built on top of a single executable that can operate in two modes:

- Monolithic mode: a single process runs all internal services. This is the mode that is used in COS Lite, where Prometheus and Loki each run as one service.
- Microservices mode: multiple processes each run a subset of services. Grafana Labs calls these subsets *roles*, with named groupings called *meta-roles*.

## The coordinator-worker pattern

Mimir, Loki and Tempo are charmed using two distinct types of charms:

1. A **coordinator charm**, which acts as the single entrypoint for all communication with the cluster. It runs an nginx reverse proxy (as per Grafana Labs' original design for these services) to route and load-balance requests across workers, verifies that the cluster is consistent (i.e. all required roles are deployed), and owns all rule files and dashboards. It also handles integration with the rest of COS. As a result, individual workers do not need to be related to other charms directly. The coordinator, based on its relations and current config options, determines the necessary workload config file that the workers must run and forwards it to them over relation data.

1. A **worker charm**, which runs one or more roles as configured by the admin via a charm config option. All units of a worker charm will have the exact same role(s). Multiple worker applications can be deployed with different roles to make a full cluster.

```{mermaid}
graph LR

subgraph mimir
mimir-write ---|mimir-cluster| coordinator
mimir-read ---|mimir-cluster| coordinator
mimir-backend ---|mimir-cluster| coordinator
end

subgraph cos
coordinator ---|alertmanager_dispatch| alertmanager
coordinator ---|grafana_dashboards| grafana
coordinator ---|ingress| Traefik
end
```

Worker roles are set via a charm config option on the worker application. Boolean per-role config variables (e.g. `role-ingester`, `role-querier`) are used as additive toggles. For a full list of roles available in charmed Mimir, Loki, and Tempo, see the [Meta-roles used in COS doc](/reference/coordinated-workers-meta-roles.md).

## Why a coordinator?

The coordinator solves several problems that would otherwise require complex distributed coordination among workers:

- Single entrypoint: all traffic flows through the coordinator's nginx reverse proxy, which load-balances across workers of the same role.
- Cleaner Juju topology: integrations with other charms (e.g. S3, alerting rules, dashboards) are established once on the coordinator, which then distributes the relevant configuration to workers.
- Consistency checking: the coordinator can verify that the cluster has all required roles covered before marking the deployment as ready, without requiring workers to cross-relate with each other.

## References
- [Coordinated worker roles and meta-roles](/reference/coordinated-workers-meta-roles.md)
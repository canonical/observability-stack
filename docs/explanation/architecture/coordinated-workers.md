---
myst:
 html_meta:
  description: "Explanation of the coordinator-worker pattern used in COS HA for Loki, Mimir, and Tempo: how it works, its components, and why it was chosen."
---

# Coordinated workers

## Overview

The telemetry backend components in the COS stack (namely Loki, Mimir, and Tempo) are built on top of a single executable that can operate in two modes:

- Monolithic mode: a single process runs all internal services. This is the mode that is used in COS Lite, where Prometheus and Loki each run as one service.
- Microservices mode: multiple processes each run a subset of services, known as *roles*.

The coordinated workers pattern is the design that COS HA (sometimes referred to as simply COS) uses to deploy these components in microservices mode, providing the high-availability (HA) topology of COS.

## Roles and meta-roles

In microservices mode, each process runs one or more *roles*. How roles are distributed varies by product:

- Mimir: each process runs an arbitrary subset of roles, or one of several predefined subsets.
- Loki: each process runs one of three predefined role subsets.
- Tempo: each process runs exactly one role.

Predefined subsets of roles are called *meta-roles*. A deployment is considered *consistent* when all roles required for the product to function are covered by at least one running process.

## The coordinator-worker pattern

Each COS HA component is made up of exactly two charms:

1. A coordinator charm, which acts as the single entrypoint for all communication with the cluster. It runs an nginx reverse proxy to route and load-balance requests across workers, verifies that the cluster is consistent (i.e. all required roles are deployed), and owns all rule files and dashboards. It also handles integration with the rest of COS. As a result, individual workers do not need to be related to other charms directly. The coordinator, based on its relations and current config options, determines the necessary workload config file that the workers must run and forwards it to them over relation data.

1. A worker charm, which runs one or more roles as configured by the operator via a config option. Multiple worker applications can be deployed with different roles to compose a full cluster. This charm runs the appropriate workload container based on the config file it receives from its coordinator.

```{mermaid}
graph LR

subgraph mimir
mimir-write ---|mimir-cluster| coordinator
mimir-read ---|mimir-cluster| coordinator
mimir-backend ---|mimir-cluster| coordinator
end

subgraph cos
coordinator ---|alertmanager_dispatch| prometheus
coordinator ---|grafana_dashboards| grafana
coordinator ---|ingress| Traefik
end
```

Worker roles are set via a config option on the worker application. Boolean per-role config variables (e.g. `role-ingester`, `role-querier`) are used rather than a free-text field, so that Juju can validate the input and prevent misconfiguration from typos.

## Why a coordinator?

The coordinator solves several problems that would otherwise require complex distributed coordination among workers:

- Single entrypoint: all traffic flows through the coordinator's nginx reverse proxy, which load-balances across workers of the same role.
- Cleaner Juju topology: integrations with other charms (e.g. S3, alerting rules, dashboards) are established once on the coordinator, which then distributes the relevant configuration to workers.
- Consistency checking: the coordinator can verify that the cluster has all required roles covered before marking the deployment as ready, without requiring workers to cross-relate with each other.

## Status and health checks

Both the coordinator and the worker report their health through Juju's `collect-status` event, which aggregates multiple status conditions and surfaces the most critical one.

### Worker health

Each worker tracks the health of its workload process through a pebble readiness check. When a readiness check endpoint is configured, the worker periodically GETs it and interprets the response:

- A `"ready"` response body (with any 2xx status code) means the worker is `up`.
- A 2xx response with any other body means the worker is still `starting` (e.g. waiting for peer workers to become available).
- An HTTP error or connection failure means the worker is `down`.

This three-state model (`starting` / `up` / `down`) is used internally by the worker to decide whether a restart is needed and to populate the Juju unit status.

When collecting unit status, the worker checks conditions in order of priority and reports the first applicable one:

| Condition | Status |
|---|---|
| Pebble container not reachable | `waiting` |
| No relation to a coordinator | `blocked` |
| Cluster relation not ready | `waiting` |
| No config published by coordinator | `waiting` |
| No roles assigned | `blocked` |
| Workload starting or down | `waiting` |
| All roles running | `active` |

### Coordinator health

The coordinator distinguishes between two levels of cluster completeness:

- Coherent (minimal deployment): all roles in the `minimal_deployment` set are covered by at least one worker. Below this threshold the cluster cannot function and the coordinator reports `blocked`.
- Recommended (robust deployment): all roles in the `recommended_deployment` set are covered with the suggested number of units. Below this threshold the cluster can function but is degraded, and the coordinator reports a `waiting` or degraded status.

The coordinator also blocks or waits on its own prerequisites:

| Condition | Status |
|---|---|
| No workers related | `blocked` |
| Cluster not coherent (missing required roles) | `blocked` |
| Cluster not at recommended deployment | `waiting` (degraded) |
| No S3 relation | `blocked` |
| S3 relation not ready | `waiting` |
| All checks pass | `active` |

Because the coordinator owns the workload config and forwards it to workers over the cluster relation, a worker that has not yet received its config will remain in `waiting` until the coordinator becomes ready and publishes it.

## References
- [Meta roles used in COS](/reference/coodinated-workers)
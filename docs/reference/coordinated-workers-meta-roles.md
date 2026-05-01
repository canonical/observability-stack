---
myst:
 html_meta:
  description: "Reference for the worker roles and meta-roles available in the Mimir, Loki, and Tempo coordinated worker deployments in COS."
---

# Coordinated worker roles and meta-roles
---

## Mimir

### Meta-roles

| Meta-role | Constituent roles |
|---|---|
| `read` | `querier`, `query-frontend` |
| `write` | `distributor`, `ingester` |
| `backend` | `alertmanager`, `compactor`, `overrides-exporter`, `query-scheduler`, `ruler`, `store-gateway` |
| `all` | `compactor`, `distributor`, `ingester`, `querier`, `query-frontend`, `ruler`, `store-gateway` |

### Roles

| Role | Part of meta-role | Min. deployment | Recommended units |
|---|---|:---:|:---:|
| `compactor` | `backend`, `all` | yes | 1 |
| `distributor` | `write`, `all` | yes | 1 |
| `ingester` | `write`, `all` | yes | 3 |
| `querier` | `read`, `all` | yes | 2 |
| `query-frontend` | `read`, `all` | yes | 1 |
| `store-gateway` | `backend`, `all` | yes | 1 |
| `ruler` | `backend`, `all` | yes | 1 |
| `alertmanager` | `backend` | no | — |
| `overrides-exporter` | `backend` | no | — |
| `query-scheduler` | `backend` | no | — |
| `flusher` | — | no | — |

---

## Loki

Loki's microservices mode uses three top-level roles (`read`, `write`, `backend`) as the primary unit of deployment. These roles are themselves the building blocks for the `all` meta-role.

### Meta-roles

| Meta-role | Constituent roles |
|---|---|
| `all` | `read`, `write`, `backend` |

### Roles

| Role | Part of meta-role | Min. deployment | Recommended units |
|---|---|:---:|:---:|
| `read` | `all` | yes | 3 |
| `write` | `all` | yes | 3 |
| `backend` | `all` | yes | 3 |

---

## Tempo

### Meta-roles

| Meta-role | Constituent roles |
|---|---|
| `all` | `querier`, `query-frontend`, `ingester`, `distributor`, `compactor`, `metrics-generator` |

### Roles

| Role | Part of meta-role | Min. deployment | Recommended units |
|---|---|:---:|:---:|
| `querier` | `all` | yes | 1 |
| `query-frontend` | `all` | yes | 1 |
| `ingester` | `all` | yes | 3 |
| `distributor` | `all` | yes | 1 |
| `compactor` | `all` | yes | 1 |
| `metrics-generator` | `all` | no | 1 |

## References
- [Grafana Mimir architecture](https://grafana.com/docs/mimir/latest/get-started/about-grafana-mimir-architecture/)
- [Mimir components](https://grafana.com/docs/mimir/latest/references/architecture/components/)
- [Loki components](https://grafana.com/docs/loki/latest/get-started/components/)
- [Tempo components](https://grafana.com/docs/tempo/latest/introduction/architecture/)
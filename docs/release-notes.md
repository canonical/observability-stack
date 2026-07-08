---
myst:
 html_meta:
  description: "Read COS 3.0 and COS Lite 3.0 release notes to track new features, review requirements and compatibility, peripheral-charm changes, and breaking and deprecated changes."
---

# Release notes

## COS 3.0 and COS Lite 3.0

*Released July 2026, long-term support (LTS).*

These release notes cover both **COS 3.0** and **COS Lite 3.0**. COS and COS Lite are distinct products with separate Terraform modules and different component sets; sections below apply to both unless noted otherwise, via a `Scope` column or an *Applies to* note.

Both tracks are LTS releases. They receive security updates and critical bug fixes for the same support window as [Ubuntu 26.04 LTS](https://ubuntu.com/about/release-cycle). If you have COS 2 or COS Lite 2 installed, plan to upgrade before **July 2026**. See the [release policy](reference/release-policy) for the full support window and cadence.

```{note}
COS `3.0` is a product version, not a single Charmhub track shared by every component. Some charms use `3.0` as their track, but most retain their own versioning; see [Component versions](#component-versions) for the exact track each charm uses in this release.
```

**Compatibility.** COS 3.0 and COS Lite 3.0 require Juju v3.6+. See [system requirements](reference/system-requirements) for the full compatibility matrix.

**Upgrade**

- [Migrate from COS 2 to COS 3.0](how-to/deploy-and-manage/upgrade.md#migrate-from-cos-2-to-cos-30)
- [Migrate from COS Lite 2 to COS Lite 3.0](how-to/deploy-and-manage/upgrade.md#migrate-from-cos-lite-2-to-cos-lite-30)

## What's new

### Reproducibility and lifecycle

#### Strict reproducibility

*Applies to: `cos`, `cos-lite`.*

Previously only charm revisions could be pinned. In COS 3.0 you can also constrain the Terraform module version and Juju behavior, so a re-deploy converges on the same result. See [Configure strict reproducibility](how-to/deploy-and-manage/configure-strict-reproducibility.md).

#### Smooth cross-track upgrades

*Applies to: `cos`, `cos-lite`.*

Upgrading from track 2 previously required a Juju admin to manually refresh every component. In COS 3.0 the upgrade path is product-managed via Terraform lifecycle definitions, so a single `terraform apply` moves the deployment to the new track. See [How to upgrade](how-to/deploy-and-manage/upgrade.md).

### Deployment topology

#### Module-managed Juju model

*Applies to: `cos`, `cos-lite`.*

`model_uuid` is no longer required as input. By default the module manages its own Juju model; pass `model = { uuid = "<uuid>" }` to target an existing one. See [Configure the Juju model](how-to/deploy-and-manage/configure-juju-model.md).

#### Granular Traefik ingress

*Applies to: `cos`, `cos-lite`.*

Previously all components were ingressed unconditionally. You can now select which components are exposed, or opt out of Traefik entirely. See [Configure granular ingress](how-to/deploy-and-manage/configure-granular-ingress.md).

#### Configurable Grafana database

*Applies to: `cos`, `cos-lite`.*

Grafana was previously limited to a single unit backed by local Juju storage. Supplying a `postgresql_offer_url` now backs Grafana with an external PostgreSQL, enabling multi-unit high availability. See [Configure the Grafana database](how-to/deploy-and-manage/configure-grafana-database.md).

### Telemetry pipelines

#### OpenTelemetry Collector pinned to v0.130

*Applies to: `cos`.*

The `opentelemetry-collector` charm workload is pinned to `v0.130` because upstream [`opentelemetry-collector-contrib`](https://github.com/open-telemetry/opentelemetry-collector-contrib) dropped the Loki exporter in [v0.131.0](https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.131.0), directing users to the OTLP exporters instead.

The `logging` integration relies on `lokiexporter` to send logs to Loki push API endpoints. Loki only recently gained an upstream OTLP endpoint, and the migration to an OTLP-first ecosystem began in 26.04. The plan is:

- **26.10**: OTLP support ecosystem-wide.
- **27.04**: the Loki Push API feature (`logging` endpoint) is dropped and the `opentelemetry-collector` charms are unpinned from `v0.130`.

## Breaking changes

The following changes apply when upgrading from COS 2 or COS Lite 2.

### Terraform inputs

| Change                                    | Scope              | Details                                                                                                                                                                          |
|-------------------------------------------|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **`channel` removed**                     | `cos`, `cos-lite`  | Replaced by a new `risk` variable. The old `channel` defaulted to `"2/stable"` and validated a `2/` prefix. Track is no longer user-facing; only risk is configurable.           |
| **`ssc.channel` removed**                 | `cos`, `cos-lite`  | No longer configurable per-component; controlled by `risk`.                                                                                                                      |
| **`s3_integrator.channel` removed**       | `cos`, `cos-lite`  | No longer configurable per-component; controlled by `risk`.                                                                                                                      |
| **`traefik.channel` removed**             | `cos`, `cos-lite`  | No longer configurable per-component; controlled by `risk`.                                                                                                                      |
| **`model_uuid` removed**                  | `cos`, `cos-lite`  | Replaced by the `model` structured object. Pass the UUID as `model = { uuid = "<uuid>" }` instead. If omitted, the module manages its own Juju model.                            |
| **`loki_worker.storage_directives` split**  | `cos`              | Single `storage_directives` replaced by three: `backend_storage_directives`, `read_storage_directives`, `write_storage_directives`.                                            |
| **`mimir_worker.storage_directives` split** | `cos`              | Split into 3 per-role storage directives.                                                                                                                                        |
| **`tempo_worker.storage_directives` split** | `cos`              | Split into 6 per-role storage directives.                                                                                                                                        |

### Terraform outputs

| Change                     | Scope              | Details                                                                                              |
|----------------------------|--------------------|------------------------------------------------------------------------------------------------------|
| **`components.ssc`**       | `cos`, `cos-lite`  | Now `try(module.ssc[0], null)`: SSC became conditional (count-based), so this output may be `null`.  |
| **`components.traefik`**   | `cos`, `cos-lite`  | Now `try(module.traefik[0], null)`: Traefik became conditional, so this output may be `null`.        |

### Peripheral charms

**Promtail is no longer maintained by Grafana Labs.** `LogProxyConsumer` relied on Promtail to scrape logs from files and forward them to Loki. Since March 2026, [Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) is no longer under active development.

Starting with COS 3.0, use [Pebble log forwarding](https://documentation.ubuntu.com/pebble/reference/log-forwarding/) from Kubernetes workloads. The `LogForwarder` object in the [`loki_push_api` charm library](https://charmhub.io/loki-k8s/libraries/loki_push_api) automates the Pebble setup. This requires the workload to emit logs to stdout (standard practice in Kubernetes).

## Non-breaking additions

### Terraform inputs

| Change                | Scope              | Details                                                       |
|-----------------------|--------------------|---------------------------------------------------------------|
| **`ingress` added**   | `cos`, `cos-lite`  | New structured object to toggle ingress per component.        |
| **`model` added**     | `cos`, `cos-lite`  | New structured object to configure the Juju model.            |

## Deprecations

- **Charmed Grafana Agent**: end-of-life July 2026, upstream vendor announced end-of-life. Plan to [migrate to charmed OpenTelemetry Collector](how-to/migrate/migrate-grafana-agent-to-otelcol).
- **Loki Push API in `opentelemetry-collector`**: the `logging` endpoint is planned for removal in the 27.04 release. Migrate telemetry pipelines to OTLP as OTLP support lands ecosystem-wide in 26.10.

## Component versions

For the full list of charms bundled in this release, along with each charm's LTS status and Charmhub track, see [COS components](reference/cos-components/index).

# Release notes

## COS 3.1 and COS Lite 3.1

*Released TODO, 2026.*

These release notes cover both **COS 3.1** and **COS Lite 3.1**. COS and COS Lite are distinct products with separate Terraform modules and different component sets; sections below apply to both unless noted otherwise, via a `Scope` column or an *Applies to* note.

3.1 is a **short-term release** on the interim track between the COS 3.0 LTS and the next LTS. It is a small, focused release: most components keep the tracks they shipped on in 3.0, and the changes below are deliberate and narrow. Short-term releases receive security updates and critical bug fixes for nine months. If you need a longer support window, stay on [COS 3.0](https://documentation.ubuntu.com/observability/track-3.0/release-notes/). See the [release policy](reference/release-policy) for the full support window and cadence.

```{note}
COS `3.1` is a product version, not a single Charmhub track shared by every component. Most charms retain their own versioning; see [Component versions](#component-versions) for the exact track each charm uses in this release.
```

**Compatibility.** COS 3.1 and COS Lite 3.1 require Juju v3.6+. See [system requirements](reference/system-requirements) for the full compatibility matrix.

**Install and upgrade**

- [Install COS 3.1 or COS Lite 3.1](how-to/deploy-and-manage/install.md)
- [Upgrade from COS 3.0 to COS 3.1 (or from COS Lite 3.0 to COS Lite 3.1)](how-to/deploy-and-manage/upgrade.md)

## What's new

### Service mesh in COS (opt-in)

*Applies to: `cos`.*

COS can now route its traffic through an [Istio service mesh](https://istio.io/), giving mutual TLS (mTLS) between components. This is opt-in and disabled by default: set `mesh_enabled = true` to turn it on.

When enabled, the module deploys an `istio-beacon` and wires it to every COS component, and — when ingress is on — deploys an `istio-ingress` that replaces Traefik as the reverse proxy. `istio-ingress` can also terminate TLS for an external CA, mirroring the Traefik path. If you have built automation or monitoring around the Traefik applications and routes, it will not apply to a mesh-enabled deployment; leave `mesh_enabled` at its default to keep the Traefik-based topology.

Two important constraints:

- **The module does not deploy the Istio control plane.** You must already have `istio-k8s` (the control plane) deployed in another Juju model, for example `istio-system`, before enabling the mesh. See the [Istio documentation](https://canonical-service-mesh-documentation.readthedocs-hosted.com/latest/istio/how-to/).
- **`mesh_enabled` and `internal_tls` are mutually exclusive.** The mesh provides mTLS between components, so internal TLS (self-signed certificates) is not used when the mesh is on. The two cannot both be enabled.

### Workload version bumps

*Applies to: `cos`, `cos-lite`.*

Two components move to newer upstream workloads in 3.1. Both bumps are per the 26.10 release cycle and are the only workload changes in this release.

| Component      | 3.0   | 3.1   | Scope                       |
| -------------- | ----- | ----- | --------------------------- |
| **Alertmanager** | 0.31  | 0.34  | `cos`, `cos-lite`           |
| **Prometheus**   | 3.11  | 3.14  | `cos-lite`                  |

Everything else ships on the same track as 3.0; see [Component versions](#component-versions) for the exact track each charm uses.

## Non-breaking additions

### Terraform inputs

| Change                  | Scope   | Details                                                                                  |
|-------------------------|---------|------------------------------------------------------------------------------------------|
| **`mesh_enabled` added**   | `cos`   | New boolean (default `false`) to route COS traffic through Istio.                        |
| **`istio_beacon` added**   | `cos`   | New structured object to configure the `istio-beacon` application.                       |
| **`istio_ingress` added**  | `cos`   | New structured object to configure the `istio-ingress` application.                      |

### Terraform outputs

| Change                     | Scope   | Details                                                                                                 |
|----------------------------|---------|---------------------------------------------------------------------------------------------------------|
| **`components.istio_beacon`**  | `cos`   | Added, `try(module.istio_beacon[0], null)`: the beacon is conditional, so this output may be `null`.    |
| **`components.istio_ingress`** | `cos`   | Added, `try(module.istio_ingress[0], null)`: istio-ingress is conditional, so this output may be `null`. |

## Deprecations

- **Charmed Grafana Agent**: end-of-life July 2026, upstream vendor announced end-of-life. Plan to [migrate to charmed OpenTelemetry Collector](how-to/migrate/migrate-grafana-agent-to-otelcol).
- **Loki Push API in `opentelemetry-collector`**: the `logging` endpoint is planned for removal in the 27.04 release. Migrate telemetry pipelines to OTLP as OTLP support lands ecosystem-wide in 26.10.

## Component versions

For the full list of charms bundled in this release, along with each charm's LTS status and Charmhub track, see [COS components](reference/cos-components/index).

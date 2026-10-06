# Release notes

## COS 3.1 and COS Lite 3.1

*Released November 2026, short-term support.*

These release notes cover both **COS 3.1** and **COS Lite 3.1**. COS and COS Lite are distinct products with separate Terraform modules and different component sets; sections below apply to both unless noted otherwise, via a `Scope` column or an *Applies to* note.

3.1 is a **short-term release** on the interim track between the COS 3.0 LTS and the next LTS. It is a small, focused release: most components keep the tracks they shipped on in 3.0, and the changes below are deliberate and narrow. Short-term releases receive security updates and critical bug fixes for nine months. If you need a longer support window, stay on the COS 3.0 LTS; see the [release policy](reference/release-policy) for the full support window, cadence, and links to each release's notes.

```{note}
COS `3.1` is a product version, not a single Charmhub track shared by every component. Most charms retain their own versioning; see [Component versions](#component-versions) for the exact track each charm uses in this release.
```

**Compatibility.** COS 3.1 and COS Lite 3.1 require Juju v3.6+. See [system requirements](reference/system-requirements) for the full compatibility matrix.

**Install and upgrade**

- [Install COS 3.1 or COS Lite 3.1](how-to/deploy-and-manage/install.md)
- [Upgrade from COS 3.0 to COS 3.1 (or from COS Lite 3.0 to COS Lite 3.1)](how-to/deploy-and-manage/upgrade.md)

## What's new

### OpenTelemetry Collector in COS Lite

*Applies to: `cos-lite`.*

COS Lite 3.1 deploys an OpenTelemetry Collector (`otelcol`, from the [opentelemetry-collector-k8s](https://charmhub.io/opentelemetry-collector-k8s) charm), which COS already had. It becomes the single point where COS Lite's own telemetry is collected, so that processing and relabelling apply uniformly, as they do in COS.

Upgrading rewires the self-monitoring integrations: components now send their telemetry to the collector, and the collector forwards it to the backend.

| Telemetry                                 | 3.0                            | 3.1                                                         |
| ----------------------------------------- | ------------------------------ | ----------------------------------------------------------- |
| Metrics of Alertmanager, Grafana, Loki    | scraped directly by Prometheus | scraped by the collector, which remote-writes to Prometheus |
| Metrics of Prometheus                     | not collected                  | scraped by the collector                                    |
| Metrics of Traefik                        | scraped directly by Prometheus | scraped by the collector                                    |
| Logs of Alertmanager, Grafana, Prometheus | sent directly to Loki          | sent to the collector, which forwards them to Loki          |

Terraform therefore replaces the `metrics_endpoint`, `loki_logging` and `traefik_self_monitoring_prometheus` integrations with collector-based ones during the upgrade; every application is upgraded in place, and none is removed or re-deployed. Telemetry already stored in Prometheus and Loki is unaffected, and the collector starts collecting as soon as the upgrade completes.

The collector is also wired into Grafana dashboards, internal TLS (`internal_tls`) and ingress (`ingress.opentelemetry_collector`), and it can be configured through the new [`opentelemetry_collector`](#terraform-inputs) input. Its default application name is `otelcol`, so if you deployed a standalone collector named `otelcol` in the same model, rename one of them before upgrading.

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
| **`opentelemetry_collector` added** | `cos-lite` | New structured object (default application name `otelcol`) to configure the OpenTelemetry Collector that 3.1 now deploys. |

### Terraform outputs

| Change                     | Scope   | Details                                                                                                 |
|----------------------------|---------|---------------------------------------------------------------------------------------------------------|
| **`components.istio_beacon`**  | `cos`   | Added, `try(module.istio_beacon[0], null)`: the beacon is conditional, so this output may be `null`.    |
| **`components.istio_ingress`** | `cos`   | Added, `try(module.istio_ingress[0], null)`: istio-ingress is conditional, so this output may be `null`. |

### Offers

| Change                           | Scope             | Details                                                                                                                       |
| -------------------------------- | ----------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **`otelcol-receive-otlp` added** | `cos`, `cos-lite` | New offer on the collector's `receive-otlp` endpoint, so applications in other models can push OTLP telemetry into the stack. |

In COS, the existing `otelcol-receive-traces` offer is unchanged.

## Removals

- **`certificates` and `send-ca-cert` offers**: *Applies to: `cos`, `cos-lite`, with `internal_tls = true`.* In 3.0 the `self-signed-certificates` application published both of its endpoints as Juju offers, for example `admin/cos-lite.certificates`. The charm module that 3.1 uses only creates offers that you explicitly ask for, and the COS modules do not, so upgrading removes these two offers. If you consume them from another model, plan for their removal before you upgrade.

## Deprecations

- **Charmed Grafana Agent**: end-of-life July 2026, upstream vendor announced end-of-life. Plan to [migrate to charmed OpenTelemetry Collector](how-to/migrate/migrate-grafana-agent-to-otelcol).
- **Loki Push API in `opentelemetry-collector`**: the `logging` endpoint is planned for removal in the 27.04 release. Migrate telemetry pipelines to OTLP as OTLP support lands ecosystem-wide in 26.10.

## Component versions

For the full list of charms bundled in this release, along with each charm's LTS status and Charmhub track, see [COS components](reference/cos-components/index).

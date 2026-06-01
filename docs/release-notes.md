---
myst:
 html_meta:
  description: "Read COS 3.0 release notes to track new features, review requirements and compatibility, peripheral-charm changes, and breaking and deprecated changes."
---

# Release notes

## COS 3.0
May 2026

These release notes cover new features and changes in COS 3.0.

COS 3.0 newer versions of all underlying charms, as well as new features around charmed opentelemetry-collector.

COS 3.0 is designated as a long-term support (LTS) release. This means it will continue to receive security updates and critical bug fixes for 15 years.

```{note}
COS track `3` is a release track for the COS bundle and does not correspond to any individual charm track on Charmhub. The individual charms retain their own versioning.
```

If you have COS 2 installed, make plans to upgrade to COS 3.0 before July 2026.

See our [release policy](reference/release-policy) and [upgrade instructions](how-to/deploy-and-manage/upgrade).

To report bugs or security issues, refer to the index of [COS components](../reference/cos-components).

## Requirements and compatibility
See [system requirements](reference/system-requirements).

COS 3.0 is compatible with Juju v3.6+.

## What's new in COS 3.0

- [Strict reproducibility with Terraform tags](explanation/operations/tagging-a-terraform-deployment.md): previously all modules were sourced with branches. New in COS 3.0, you can reference the module with a tag. For example `?ref=tf-cos-3.0.0`.
- [Granular Traefik ingress](how-to/deploy-and-manage/configure-granular-ingress.md): previously all components were ingressed. New in COS 3.0, you can be selective, or remove ingress entirely.
- [Smooth cross-track upgrades via lifecycled resources](how-to/deploy-and-manage/upgrade/#migrate-from-cos-lite-2-to-cos-lite-3): previously, a Juju admin had to manually refresh all components to the new track. New in COS 3.0, you can upgrade to the next track with a single `terraform apply`, since the upgrade path is product-managed via Terraform lifecycle definitions.
- **Opentelemetry collector**. Charmed opentelemetry-collector's workload is pinned to version 0.130 because the upstream `opentelemetry-collector-contrib` [project](https://github.com/open-telemetry/opentelemetry-collector-contrib) dropped support for Loki exporter in [release v0.131.0](https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.131.0), stating that users can migrate to the OTLP exporters instead.
  - The logging integrations for the `opentelemetry-collector` charms rely on `lokiexporter` to send logs to Loki push API endpoints. Loki only recently received upstream support for an OTLP endpoint, and migrating to an OTLP-first ecosystem in COS began in 26.04. The objective is to have support for OTLP ecosystem-wide by the end of 26.10 and to deprecate the Loki Push API feature (`logging` endpoint). Support will then be fully dropped in 27.04, and the `opentelemetry-collector` charms will no longer be pinned to `v0.130`.

## Terraform product changes

### Breaking changes in COS 3.0 (from COS 2)

#### Inputs

| Change | Scope | Details |
|--------|-------|---------|
| **`channel` removed** | `cos`, `cos-lite` | Replaced by a new `risk` variable. The old `channel` had a default of `"2/stable"` and validated a `2/` prefix. Track is no longer user-facing: only risk is configurable. |
| **`ssc.channel` removed** | `cos`, `cos-lite` | No longer configurable per-component; controlled by `risk`. |
| **`s3_integrator.channel` removed** | `cos`, `cos-lite` | No longer configurable per-component; controlled by `risk`. |
| **`traefik.channel` removed** | `cos`, `cos-lite` | No longer configurable per-component; controlled by `risk`. |
| **`loki_worker.storage_directives` split** | `cos` | Single `storage_directives` replaced by three: `backend_storage_directives`, `read_storage_directives`, `write_storage_directives`. |
| **`mimir_worker.storage_directives` split** | `cos` | Same as above: split into (3) per-role storage directives. |
| **`tempo_worker.storage_directives` split** | `cos` | Same as above: split into (6) per-role storage directives. |

#### Outputs

| Change | Scope | Details |
|--------|-------|---------|
| **`components.ssc`** | `cos`, `cos-lite` | Now `try(module.ssc[0], null)` — SSC became conditional (count-based), so this output may be `null`. |
| **`components.traefik`** | `cos`, `cos-lite` | Now `try(module.traefik[0], null)` — Traefik became conditional, so this output may be `null`. |

### Non-breaking changes

#### Inputs

| Change | Scope | Details |
|--------|-------|---------|
| **`base` added** | `cos`, `cos-lite` | New variable for the component bases. |
| **`ingress` added** | `cos`, `cos-lite` | New structured object to toggle ingress per component. |

### COS components

| Component                | Version |
|--------------------------|---------|
| alertmanager             | 0.31    |
| catalogue                |         |
| grafana                  | 12.4    |
| loki                     | 3.7     |
| mimir                    | 2.17    |
| opentelemetry-collector  | 0.130   |
| s3-integrator            |         |
| self-signed-certificates |         |
| tempo                    | 2.10    |
| traefik                  | 2.11    |


### COS Lite components

| Component                | Version |
|--------------------------|---------|
| alertmanager             | 0.31    |
| catalogue                |         |
| grafana                  | 12.4    |
| loki                     | 3.7     |
| prometheus               | 3.11    |
| traefik                  | 2.11    |

## Notable changes in peripheral charms

### Promtail is no longer maintained by Grafana Labs
LogProxyConsumer is relying on promtail for scraping log lines from files, and sending them to Loki.
Since March 2026, [promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) is no longer under active development by Grafana Labs.
Starting COS 3.0, it is recommended to use [pebble for forwarding logs](https://documentation.ubuntu.com/pebble/reference/log-forwarding/) from kubernetes workloads.
You can use the `LogForwarder` object from the [`loki_push_api` charm library](https://charmhub.io/loki-k8s/libraries/loki_push_api)  to automatically set up pebble for log forwarding.

Note that for this to work, the workload needs to emit logs to stdout (this is standard practice in kubernetes).

## Backwards-incompatible changes
- If you are using charmed Grafana Agent to push telemetry to COS, note that the vendor announced end-of-life, so we will not be supporting the charm beyond July 2026. Make plans to [upgrade to charmed OpenTelemetry Collector](how-to/migrate/migrate-grafana-agent-to-otelcol).

## Deprecated features

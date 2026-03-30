---
myst:
 html_meta:
  description: "Read COS 2 release notes to track new features, review requirements and compatibility, peripheral-charm changes, and breaking and deprecated changes."
---

# COS 3 release notes
May 2026

These release notes cover new features and changes in COS 3.

COS 3 newer versions of all underlying charms, as well as new features around charmed opentelemetry-collector.

COS 3 is designated as a long-term support (LTS) release. This means it will continue to receive security updates and critical bug fixes for 15 years.

```{note}
COS track `3` is a release track for the COS bundle and does not correspond to any individual charm track on Charmhub. The individual charms retain their own versioning.
```

If you have COS 2 installed, make plans to upgrade to COS 3 before July 2026.

See our [release policy](release-policy.md) and [upgrade instructions](../how-to/upgrade.md).

To report bugs or security issues, refer to the index of [COS components](../reference/cos-components).

## Requirements and compatibility
See [system requirements](system-requirements.md).

COS 3 is compatible with Juju v3.6+.


## What's new in COS 3


### COS components

| Component                | Version |
|--------------------------|---------|
| alertmanager             | 0.x     |
| catalogue                |         |
| grafana                  | 12.x    |
| loki                     | 3.x     |
| mimir                    | 3.x     |
| opentelemetry-collector  | 0.x     |
| s3-integrator            |         |
| self-signed-certificates |         |
| tempo                    | 2.x     |
| traefik                  | 2.x     |


### COS Lite components

- Terraform modules for [COS](https://github.com/canonical/observability-stack/tree/main/terraform/cos)
  and [COS Lite](https://github.com/canonical/observability-stack/tree/main/terraform/cos-lite).
  As Juju bundles are deprecated, the standard way of deploying COS is now using the
  [Juju Terraform provider](https://registry.terraform.io/providers/juju/juju/latest/docs).
  - [Telemetry correlation](../explanation/telemetry-correlation.md) is now automatically enabled when you deploy COS using the
    Terraform module.
- **Grafana v12**. We upgraded the workload version from Grafana 9 to Grafana 12. A thorough review of Grafana's breaking changes and how they affect us is available [on Discourse](https://discourse.charmhub.io/t/cos-will-start-using-grafana-12-what-changed/18868).
- **Opentelemetry collector**. Charmed opentelemetry-collector was released. The charm was designed to be a drop-in replacement for the grafana-agent charm (upstream grafana-agent is EOL since November 2025, and we will support charmed grafana-agent until July 2026).
  - The workload is pinned to version 0.130 because the upstream `opentelemetry-collector-contrib` [project](https://github.com/open-telemetry/opentelemetry-collector-contrib) dropped support for Loki exporter in [release v0.131.0](https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.131.0), stating that users can migrate to the OTLP exporters instead.
    - The logging integrations for the `opentelemetry-collector` charms rely on `lokiexporter` to send logs to Loki push API endpoints. Loki only recently received upstream support for an OTLP endpoint, and migrating to an OTLP-first ecosystem in COS began in 26.04. The objective is to have support for OTLP ecosystem-wide by the end of 26.10 and to deprecate the Loki Push API feature (`logging` endpoint). Support will then be fully dropped in 27.04, and the `opentelemetry-collector` charms will no longer be pinned to `v0.130`.
- `extra_alert_labels` config option. A new config option in grafana-agent and opentelemetry-collector enabled adding custom labels to alert rules. Custom labels are useful for differentiating alerts coming from sites with different SLAs.
- **API links in catalogue-k8s**. The cards in catalogue-k8s now support extra links for documentation and APIs. COS charms now provide links to the workload API, making it easier to locate ingress URLs
for workloads without a web UI.


## Notable changes in peripheral charms


## Backwards-incompatible changes
- If you are using charmed Grafana Agent to push telemetry to COS, note that the vendor announced end-of-life, so we will not be supporting the charm beyond July 2026. Make plans to [upgrade to charmed OpenTelemetry Collector][../how-to/migrate-grafana-agent-to-otelcol].

## Deprecated features

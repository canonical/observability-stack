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

- **Opentelemetry collector**. Charmed opentelemetry-collector's workload is pinned to version 0.130 because the upstream `opentelemetry-collector-contrib` [project](https://github.com/open-telemetry/opentelemetry-collector-contrib) dropped support for Loki exporter in [release v0.131.0](https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.131.0), stating that users can migrate to the OTLP exporters instead.
  - The logging integrations for the `opentelemetry-collector` charms rely on `lokiexporter` to send logs to Loki push API endpoints. Loki only recently received upstream support for an OTLP endpoint, and migrating to an OTLP-first ecosystem in COS began in 26.04. The objective is to have support for OTLP ecosystem-wide by the end of 26.10 and to deprecate the Loki Push API feature (`logging` endpoint). Support will then be fully dropped in 27.04, and the `opentelemetry-collector` charms will no longer be pinned to `v0.130`.

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


## Notable changes in peripheral charms


## Backwards-incompatible changes
- If you are using charmed Grafana Agent to push telemetry to COS, note that the vendor announced end-of-life, so we will not be supporting the charm beyond July 2026. Make plans to [upgrade to charmed OpenTelemetry Collector][../how-to/migrate-grafana-agent-to-otelcol].

## Deprecated features

# COS 2 release notes
October 2025

These release notes cover new features and changes in COS 2.

COS 2 is designated as a short-term support release. This means it will continue to receive security updates and critical bug fixes for 9 months.

See our [release policy](release-policy.md) and [upgrade instructions](../how-to/upgrade.md).

## Requirements and compatibility
See [system requirements](system-requirements.md).

COS 2 is compatible with Juju v3.6+.

## What's new in COS 2

- Terraform modules for COS and COS Lite.
- **Grafana v12**. We upgraded the workload version from Grafana 9 to Grafana 12. A thorough review of Grafana's breaking changes and how they affect us is available [on Discourse](https://discourse.charmhub.io/t/cos-will-start-using-grafana-12-what-changed/18868).
- **Opentelemetry collector**. Opentelemetry-collector was released and is to replace the deprecated grafana-agent (goes EOL in November 2025).
- `extra_alert_labels` config option. A new config option in grafana-agent and opentelemetry-collector enabled adding custom labels to alert rules. Custom labels are useful for differentiating alerts coming from sites with different SLAs.
- **API links in catalogue-k8s**. The cards in catalogue-k8s now support extra links for documentation and APIs. COS charms now provide links to the workload API, making it easier to locate ingress URLs
for workloads without a web UI.

## Notable changes in peripheral charms
- Multiple scripts in script-exporter. The script exporter VM charm can now take an archive of scripts. It can now be deployed on 20.04, 22.04 and 24.04.
- Prior to cos-proxy `rev166`, duplicate telemetry exists after `upgrade` and `config-changed` hooks. Follow [these remediation steps](https://github.com/canonical/cos-proxy-operator/issues/208#issuecomment-3367094739) to resolve, requiring you to upgrade cos-proxy to `>=rev166` via `track2`. This also includes the feature of scrape-configs and alert rules for `cos-agent` relations.

## Backwards-incompatible changes
- Charms from track 2 can be deployed on juju models v3.6+.
- Terraform module variable `model_name` renamed to `model` in all charms.
- Grafana v12 changes how the panel view URL is generated for repeated panels. Links to **repeated panels** in a dashboard changed slightly; previously bookmarked links to a repeated panel (not its dashboard) will no longer work.


## Deprecated features
- The `LogProxyConsumer` charm library (owned by Loki) is deprecated. Use Pebble log forwarding instead.

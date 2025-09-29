# Release notes for track 2

## Requirements and compatiblity
See [system requirements](system-requirements.md).

Track 2 is compatible with Juju v3.6+.

## What's new

### Terraform modules for COS and COS Lite


### Grafana v12

We upgraded the workload version from Grafana 9 to Grafana 12.

A thorough review of Grafana's breaking changes and how they affect us is available [on Discourse](https://discourse.charmhub.io/t/cos-will-start-using-grafana-12-what-changed/18868).

#### Changes to how the panel view URL is generated for repeated panels

Links to **repeated panels** in a dashboard changed slightly; previously bookmarked links specifically to a repeated panel (not its dashboard) won't work anymore.


### Loki v3

We upgraded the workload version from 2.9.x to 3.y. (TODO)

Upstream [upgrade guide](https://grafana.com/docs/loki/latest/setup/upgrade/).

v3.0:
- In track/1, we already use TSDB v13 schema, which is the default for Loki v3 in track/2.
- BoltDB (`boltdb-shipper`) is [deprecated](https://grafana.com/docs/loki/latest/configure/storage/#boltdb-deprecated).
  - TODO: add to track/1 -> 2 upgrade guide to refresh to the latest track/1 and wait the retention period to elapse before upgrading to track/2. This would ensure that all data is in the v13 schema.
  - TODO: with the introduction on loki 3, drop the [code](https://github.com/canonical/loki-k8s-operator/blob/0a1e101729d614aaef1198098d7a2ce7df83f8ea/src/config_builder.py#L137) that addresses boltdb.

v3.1:
- TODO: make sure lokitool is built in the rock

v3.4:
- TODO: Promtail is deprecated. Will need to switch to pebble "eventually".

See upstream release notes for more details: [v3.0](https://grafana.com/docs/loki/latest/release-notes/v3-0/).


## Deprecations and removed functionality


## Known issues


## Upgrade notes

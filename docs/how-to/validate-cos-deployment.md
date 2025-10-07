# Validate COS deployment

## Juju model
- `juju model-config automatically-retry-hooks` is set to True.
- Inspect resource limits for loki, mimir, tempo.
- All oci resources are from dockerhub, not ghcr or any others.

## Disk space
- PVC volume should be >> the default 1Gi (ref: [OB064 - Storage defaults in charmcraft.yaml](https://docs.google.com/document/d/1svdvHOc-w2GW0X1YN329hHv9mBPQJCeplGLrT7mOt7I/edit?tab=t.0#heading=h.gpxo73gc28w1)).
- WAL in Loki, Mimir, should be substantial.
- S3 storage used should increase incrementally.
    - Mimir's [`compactor.compaction_interval`](https://grafana.com/docs/mimir/latest/configure/configuration-parameters/#compactor) is 1h by default.
    - Loki's [`compactor.compaction_interval`](https://grafana.com/docs/loki/latest/operations/storage/retention/#retention-configuration) is 10m by default.

## Data
- A dedicated s3-integrator charm per loki, mimir, tempo.
- S3 bucket names are set as a config option in the s3-integrator charms.

## Alertmanager
- Inspect firing alerts. Only the watchdog should fire.
- Alert labels are sufficient for 1:1 identification if alert origin.
- Confirm alerts reach pagerduty.

## Grafana
- All data sources pass connectivity test.
- Inspect selfmon dashboards. Make sure "no data" only in panels where it makes sense.

## HA
- Repeatedly query the loki/mimir app IP while kubectl-deleting 2 out of its 3 worker nodes.
- (How to simulate ceph node outage?)

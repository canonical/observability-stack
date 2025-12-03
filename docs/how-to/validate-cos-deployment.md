# Validate COS deployment

## Juju model
- `juju model-config automatically-retry-hooks` is set to True.
- Inspect resource limits for Loki, Mimir, Tempo.

## Disk space
- PVC volume should be >> the default 1Gi.
- WAL in Loki, Mimir, should be substantial.
- S3 storage used should increase incrementally.
    - [`compactor.compaction_interval`](https://grafana.com/docs/mimir/latest/configure/configuration-parameters/#compactor) for Mimir is 1h by default.
    - [`compactor.compaction_interval`](https://grafana.com/docs/loki/latest/operations/storage/retention/#retention-configuration) for Loki is 10m by default.

## Data
- A dedicated s3-integrator charm per Loki, Mimir, Tempo.
- S3 bucket names are set as a config option in the s3-integrator charms.
- S3 buckets for Loki, Mimir, Tempo are not empty.

## Alertmanager
- Inspect firing alerts. Only the watchdog should fire.
- Alert labels are sufficient for 1:1 identification of alert origin.
- Confirm alerts reach PagerDuty.

## Grafana
- All data sources pass connectivity test.
- Inspect the self-monitoring dashboards. Make sure "no data" only in panels where it makes sense.

## HA
- Repeatedly query the Loki/Mimir app IP while `kubectl`-deleting 2 out of its 3 worker nodes.
- (How to simulate Ceph node outage?)

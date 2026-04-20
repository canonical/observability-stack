---
myst:
 html_meta:
  description: "Use COS storage best practices to estimate telemetry volume, set up distributed storage, and avoid retention or performance bottlenecks over time."
---

# Storage best practices

Use this document to plan storage for a COS or COS Lite deployment.

## Evaluate storage volume needs
Evaluate the [telemetry volume needed](/how-to/configure-and-tune/evaluate-telemetry-volume) for your solution
and refer to the [sizing guide](system-requirements) for concrete numbers.

## Set up distributed storage

In production, **do not** use hostPath storage ([`hostpath-storage`](https://canonical.com/microk8s/docs/addon-hostpath-storage) in MicroK8s; `local-storage` in Canonical K8s):

- `PersistentVolumeClaims` created by the host path storage provisioner are bound to the local node, so it is *impossible to move them to a different node*.
- A `hostpath` volume can *grow beyond the capacity set in the volume claim manifest*.

### Canonical K8s

Use Ceph CSI. Refer to Canonical Kubernetes [snap](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/storage/ceph/)
and [charm](https://documentation.ubuntu.com/canonical-kubernetes/latest/charm/howto/ceph-csi/) docs.

### MicroK8s

Use the [`rook-ceph`](https://canonical.com/microk8s/docs/addon-rook-ceph) add-on together with Microceph.
See the [Microceph tutorial](https://canonical.com/microk8s/docs/how-to-ceph).

## General-purpose storage recommendations

The following storage recommendations are based on:
- retention period of 30 days;
- 10k log lines per minute;
- 400k metrics per minute.

### COS
#### Kubernetes persistent volume storage

The default storage allocation for charmed persistent volumes is 1GB. The following mount points typically require non-default storage allocations.

| Charm                       | Role              | Storage volume   | Description                                                    | Capacity     | Typical unit count |
| --------------------------- | ----------------- | ---------------- | -------------------------------------------------------------- | ------------ | ------------------ |
| loki-worker-k8s             | write or ingester | loki-persisted   | WAL for received logs before they are sent off to S3           | 100GB        | 3                  |
| mimir-worker-k8s            | write or ingester | data             | WAL for received metrics before they are sent off to S3        | 50GB  | 3                  |
| tempo-worker                | ingester          | data             | WAL for received traces                                        | 100GB        | 3                  |
| grafana-k8s                 | -                 | database         | Configurations, plugins, user data                             | 10GB         | 3                  |
| alertmanager-k8s            | -                 | data             | `nflog` and silences snapshots                                    | 1GB          | 3                  |
| opentelemetry-collector-k8s | -                 | persisted        | Self-monitoring queued telemetry                               | 10GB         | 1                  |
| traefik-k8s                 | -                 | configurations   | Dynamic configuration files (YAML), x509 certificates and keys | 1GB          | 1                  |
| cos-configuration-k8s       | -                 | content-from-git | Checked-out content from the git repository                    | 1GB          | 1                  |

The total Kubernetes persistent volume storage needed by COS depends on the scale of each application, and on the replication count.
For the table above, a COS deployment would require 795 GB per replicated storage pool (e.g. MicroCeph).

#### S3 buckets

Telemetry is stored in S3 for long-term storage, decoupling storage from compute and supporting cost-effective retention policies.
The S3 Integrator provides integration with S3-compatible object storage backends (e.g. Rados Gateway). The object storage should be backed by a 3x replication pool.

| Bucket name | Bucket size |
| ----------- | ----------- |
| loki        | 1TB         |
| mimir       | 500GB       |
| tempo       | 200GB       |

The total object storage needed by COS depends on the replication count. For the table above, a COS deployment would require 1.7 TB per replicated storage pool.


### COS Lite

#### Kubernetes persistent volume storage

The default storage allocation for charmed persistent volumes is 1GB. The following mount points typically require non-default storage allocations.

| Charm                       | Storage volume   | Description                                                    | Capacity     | Typical unit count |
| --------------------------- | ---------------- | -------------------------------------------------------------- | ------------ | ------------------ |
| loki-k8s                    | loki-chunks      | WAL for received logs                                          | 100GB        | 3                  |
| prometheus-k8s              | database         | WAL for received metrics                                       | 50GB  | 3                  |
| grafana-k8s                 | database         | Configurations, plugins, user data                             | 10GB         | 1                  |
| alertmanager-k8s            | data             | `nflog` and silences snapshots                                    | 1GB          | 3                  |
| traefik-k8s                 | configurations   | Dynamic configuration files (YAML), x509 certificates and keys | 1GB          | 1                  |
| cos-configuration-k8s       | content-from-git | Checked-out content from the git repository                    | 1GB          | 1                  |

The total Kubernetes persistent volume storage needed by COS depends on the scale of each application, and on the replication count.
For the table above, a COS Lite deployment would require 465 GB per replicated storage pool (e.g. MicroCeph).

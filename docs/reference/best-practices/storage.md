# Storage Best Practices

## Evaluate storage volume needs
Evaluate the [telemetry volume needed](../../how-to/evaluate-telemetry-volume) for your solution
and refer to the storage [sizing guideline](https://discourse.charmhub.io/t/cos-lite-ingestion-limits-for-8cpu-16gb-ssd/13005) for concrete numbers.

For example, a deployment that handles roughly:

- 1M metrics/min from 150 targets; and
- 100k log lines/min for about 150 targets

has a growth rate of about 50GB per day under normal operations.
So, if you want a retention interval of about two months, you'll need 3TB of storage only for the telemetry.

## Set up distributed storage
In production, **do not** use hostPath storage ([`hostpath-storage`](https://microk8s.io/docs/addon-hostpath-storage) in MicroK8s; `local-storage` in Canonical K8s):
- `PersistentVolumeClaims` created by the host path storage provisioner are bound to the local node, so it is *impossible to move them to a different node*.
- A `hostpath` volume can *grow beyond the capacity set in the volume claim manifest*.

### Canonical K8s
Use Ceph CSI. Refer to Canonical Kubernetes [snap](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/howto/storage/ceph/)
and [charm](https://documentation.ubuntu.com/canonical-kubernetes/latest/charm/howto/ceph-csi/) docs.

### MicroK8s
Use the [`rook-ceph`](https://microk8s.io/docs/addon-rook-ceph) add-on together with Microceph.
See the [Microceph tutorial](https://microk8s.io/docs/how-to-ceph).

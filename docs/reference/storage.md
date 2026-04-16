---
myst:
 html_meta:
  description: "Use COS storage best practices to estimate telemetry volume, set up distributed storage, and avoid retention or performance bottlenecks over time."
---

# Storage Best Practices

## Evaluate storage volume needs
Evaluate the [telemetry volume needed](../../how-to/configure-and-tune/evaluate-telemetry-volume) for your solution
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

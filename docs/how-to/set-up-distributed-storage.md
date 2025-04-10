# Set up distributed storage

```{warning}
This guide will show you how to set up a single-node cluster. While this works great for
development environment, it is by no means suitable for a production setup due to the lack
of replication and resilience.
```

## Introduction

[MicroCeph](https://canonical-microceph.readthedocs-hosted.com/) is a lightweight way of deploying a Ceph cluster, without much of the operational overhead. In this how-to guide, you will learn how to set it up, add some storage, and connect it to MicroK8s for usage in the Canonical Observability Stack.

## Prerequisites

* A working deployment of MicroK8s, as per [this tutorial](/tutorial/installation/getting-started-with-cos-lite).

## Install MicroCeph

Install the most recent stable release of MicroCeph:

```
$ sudo snap install microceph
```

## Hold snap updates

Allowing the snap to be auto-updated can lead to unintended consequences. In enterprise environments especially, it is best to research the ramifications of software changes before those changes are implemented. So, as recommended by the [MicroCeph maintainers](https://canonical-microceph.readthedocs-hosted.com/en/latest/how-to/single-node), prevent the software from being auto-updated.

```bash
$ sudo snap refresh --hold microceph
```

## Bootstrap the cluster

We need to bootstrap the Ceph cluster:

```bash
$ sudo microceph cluster bootstrap
```


At this point we can check the status of the cluster and query the list of available disks that should be empty. The disk status is queried with:

```bash
$ sudo microceph.ceph status
```

Its output should look like:
```
  cluster:
    id:     9539a8ee-825a-462a-94fa-15613c09cab1
    health: HEALTH_WARN
            mon charm-dev-juju-34 is low on available space

  services:
    mon: 1 daemons, quorum charm-dev-juju-34 (age 8s)
    mgr: charm-dev-juju-34(active, since 3s)
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
```


## Add storage

```{note}
In a production environment, we would instead [assign physical block devices to OSDs](https://canonical-microceph.readthedocs-hosted.com/en/latest/how-to/multi-node/#add-storage). For this guide, however, we will make use of file backed OSDs for simplicity.
```

Three OSDs will be required to form a minimal Ceph cluster. Add the OSDs to the cluster by using the disk add command. In the example, each OSD will be sized to 4GB:

```bash
$ sudo microceph disk add loop,4G,3
```

## Connect MicroCeph to MicroK8s

We will now enable the `rook-ceph` plugin in MicroK8s. For more details, see the upstream documentation about the [`rook-ceph` add-on](https://microk8s.io/docs/addon-rook-ceph).


```bash
$ sudo microk8s enable rook-ceph
```

As we have already set up MicroCeph, we'll now make it managed by Rook.

```bash
$ sudo microk8s connect-external-ceph
```

At the end of this process you should have a storage class ready to use:

```bash
$ kubectl get sc
NAME       PROVISIONER                  RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
ceph-rbd   rook-ceph.rbd.csi.ceph.com   Delete          Immediate           true                   1s
```

And with that, we're done! Good job! Your persistent volumes on MicroK8s will henceforth be backed by
MicroCeph storage.

## See also
- [Charmed Ceph](https://ubuntu.com/ceph/docs)
- [Charmed MicroCeph](https://charmhub.io/microceph)
- [How to setup MicroK8s with (Micro)Ceph storage](https://microk8s.io/docs/how-to-ceph)
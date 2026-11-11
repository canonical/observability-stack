---
myst:
  html_meta:
    description: "How to migrate Charmed Pyroscope from v1 to v2"
---

# How to migrate Charmed Pyroscope from v1 to v2 

Pyroscope 2.1 and later use a new storage architecture. They cannot query profiles
written by Pyroscope 1, so migrate by deploying the newer version beside your
existing deployment.

Keep the v1 deployment until you no longer need its profile history. The old data
remains in its S3 bucket, but Pyroscope 2.1 and later cannot read it.

## Prerequisites

Before migrating, make sure you have:

- a Charmed Pyroscope deployment running Pyroscope 1.x
- a separate S3 bucket for Pyroscope 2.1 or later
- enough capacity to run both deployments during the migration
- the charm channel that ships Pyroscope 2.1 or later


```{note}
The `2/edge` channel shown in older Charmed Pyroscope guides ships
Pyroscope 1.x. Replace `<v2-channel>` below with a channel that ships Pyroscope
2.1 or later.
```

## Deploy Pyroscope 2.1 or later

Deploy the newer version with application names that do not conflict with your v1
deployment. The `pyroscope-v2` names below are examples:

```bash
juju deploy pyroscope-coordinator-k8s pyroscope-v2 \
  --channel <v2-channel> --trust
juju deploy pyroscope-worker-k8s pyroscope-v2-worker \
  --channel <v2-channel> --trust --config role-all=true
juju integrate pyroscope-v2 pyroscope-v2-worker
```

Configure a separate `s3-integrator` for the new bucket, then integrate it with
the new coordinator:

```bash
juju deploy s3-integrator pyroscope-v2-s3 --channel 2/stable --trust
juju config pyroscope-v2-s3 endpoint=<s3-endpoint> bucket=<v2-bucket>
juju run pyroscope-v2-s3/leader sync-s3-credentials \
  access-key=<access-key> secret-key=<secret-key>
juju integrate pyroscope-v2:s3 pyroscope-v2-s3
```

Wait until the coordinator and worker report `active` in `juju status`.

For a production deployment, use separate workers for the required roles instead
of the single `role-all` worker shown here.

## Send profiles to Pyroscope 2.1 or later

Integrate each charmed application with the new coordinator:

```bash
juju integrate <application>:profiling pyroscope-v2:profiling
```

Keep the application's existing relation with v1 while you verify the new
deployment. Applications using a fixed Pyroscope URL must be pointed at the new
coordinator separately.

## Verify the new deployment

Do not rely only on `juju status` or a successful push. Confirm that a recent
profile can be queried from the new datasource in Grafana Explore.

Keep using both deployments until profiles captured before the new version was
deployed have passed the history window you need from v1.

## Complete the migration

Remove each application's relation with the v1 coordinator:

```bash
juju remove-relation <application>:profiling pyroscope:profiling
```

Check again that new profiles appear in the new deployment. When you no longer
need the v1 profile history, remove the v1 coordinator and all its worker
applications.

If you need to stop before removing v1, remove the new relations and continue using
the original deployment. No data is converted or moved during this process.

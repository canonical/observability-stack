---
myst:
  html_meta:
    description: "Configure charm revision and image pins for strict reproducibility in deployments."
---

# How to configure COS for strict reproducibility

To limit variance in COS deployments, the COS Terraform module can be pinned in a variety of ways.

## Pinning the Terraform module

To restrict variance in the Terraform layer, the COS Terraform module source can be pinned to a tag. Consult the [Terraform Module Versioning](../../explanation/operations/terraform-module-versioning.md) documentation for specifics.

## Pinning charm revisions and resource images

To restrict variance in the Juju layer, the COS Terraform module offers per-component `revision` and `resources` configuration. See the [available COS Terraform configuration](../../../terraform/cos/variables.tf) for details. Pinning the values of these fields ensures that the deployed Juju applications remain unchanged, until they are explicitly targeted for an upgrade.

### Pin a component

To pin the `alertmanager` component, the charm `revision` and `resources.alertmanager-image` are specified according to:

```hcl
module "cos" {
  source     = "git::https://github.com/canonical/observability-stack.git//terraform/cos"
  alertmanager = {
    resources = {
      alertmanager-image = "ubuntu/alertmanager:0.28.0-24.04_stable"
    }
    revision = 212
  }
}
```

The deployed charm revision:
```shell
juju status --format=json | jq -r '.applications["alertmanager"]["charm-rev"]'

212
```

The hash of the specified image: [0.28.0-24.04_stable](https://hub.docker.com/layers/ubuntu/alertmanager/0.28.0-24.04_stable/images/sha256-c87440d8da4f693a15de287cf49368904dfdfb59ecb2a60c6dada294fb931158) can be seen in the pod's container:
```shell
kubectl describe pod -n cos alertmanager-0 | grep -A 50 "Containers" | grep -A 3 "alertmanager:"

  alertmanager:
    Container ID:  containerd://f6ac72ebc579dc96afea6600f29ab77a6fe6cc6c17fe94ff47aae0173bed8108
    Image:         ubuntu/alertmanager@sha256:c87440d8da4f693a15de287cf49368904dfdfb59ecb2a60c6dada294fb931158
    Image ID:      docker.io/ubuntu/alertmanager@sha256:c87440d8da4f693a15de287cf49368904dfdfb59ecb2a60c6dada294fb931158
```

### Update a pinned component

To upgrade the Alertmanager component, update the charm `revision` and the `alertmanager-image` accordingly. For example, to [0.31-24.04_stable image](https://hub.docker.com/layers/ubuntu/alertmanager/0.31-24.04_stable/images/sha256-c7bb054a27fdad7412fcb401b1fde27598e4e65f1671d080f07b5fddfbe7d986) according to:

```hcl
module "cos" {
  source     = "git::https://github.com/canonical/observability-stack.git//terraform/cos"
  alertmanager = {
    resources = {
      alertmanager-image = "ubuntu/alertmanager:0.31-24.04_stable"
    }
    revision = 212
  }
}
```

```shell
kubectl describe pod -n cos alertmanager-0 | grep -A 50 "Containers" | grep -A 3 "alertmanager:"

  alertmanager:
    Container ID:  containerd://7639eeeaa144b2aabe0fe8657443ccee455a42a253eb23766c5bd22538eac09c
    Image:         ubuntu/alertmanager@sha256:c7bb054a27fdad7412fcb401b1fde27598e4e65f1671d080f07b5fddfbe7d986
    Image ID:      docker.io/ubuntu/alertmanager@sha256:c7bb054a27fdad7412fcb401b1fde27598e4e65f1671d080f07b5fddfbe7d986
```

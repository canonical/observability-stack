---
myst:
  html_meta:
    description: "Configure charm revision and image pins for strict reproducibility in deployments."
---

# How to configure COS for strict reproducibility

In production environments, users usually want to limit the variance of a deployment as much as possible. To reduce variance in COS deployments, users can pin the component's charm revision and resource images. This ensures that between applies, the components remain unchanged, unless it was explicitly targeted for upgrades.

## Pin a component's charm revision and resource image

The COS Terraform module offers per-component `revision` and `resources` configuration. See the [available COS Terraform configuration](../../../terraform/cos/variables.tf) for details.

```{warning}
When charm revision pinning is desired, you must also pin the charm's resource images due to this known issue in CharmHub:
- TODO
```

It is your responsibility as the user of the product to determine the correct combinations of charm revisions and resource images. This is a configuration override that has no guarantee for all combinations.

### Pin a component

To pin the Alertmanager component, the charm `revision` is set to `212` and the `alertmanager-image` to [image 0.28.0-24.04_stable](https://hub.docker.com/layers/ubuntu/alertmanager/0.28.0-24.04_stable/images/sha256-c87440d8da4f693a15de287cf49368904dfdfb59ecb2a60c6dada294fb931158) according to:

```hcl
module "cos" {
  source     = "git::https://github.com/canonical/observability-stack.git//terraform/cos"
  alertmanager = {
    resources = {
      alertmanager-image = "ubuntu/alertmanager@sha256:c87440d8da4f693a15de287cf49368904dfdfb59ecb2a60c6dada294fb931158"
    }
    revision = 212
  }
}
```

and when applied, the resulting charm revision and resource image are deployed:
```shell
juju status --format=json | jq -r '.applications["alertmanager"]["charm-rev"]'

212
```

```shell
kubectl describe pod -n cos alertmanager-0 | grep -A 50 "Containers" | grep -A 3 "alertmanager:"

  alertmanager:
    Container ID:  containerd://f6ac72ebc579dc96afea6600f29ab77a6fe6cc6c17fe94ff47aae0173bed8108
    Image:         ubuntu/alertmanager@sha256:c87440d8da4f693a15de287cf49368904dfdfb59ecb2a60c6dada294fb931158
    Image ID:      docker.io/ubuntu/alertmanager@sha256:c87440d8da4f693a15de287cf49368904dfdfb59ecb2a60c6dada294fb931158
```

### Update an already-pinned component

To upgrade the Alertmanager component, update the charm `revision` and the `alertmanager-image` accordingly. For example, to [0.31-24.04_stable image](https://hub.docker.com/layers/ubuntu/alertmanager/0.31-24.04_stable/images/sha256-c7bb054a27fdad7412fcb401b1fde27598e4e65f1671d080f07b5fddfbe7d986) according to:

```hcl
module "cos" {
  source     = "git::https://github.com/canonical/observability-stack.git//terraform/cos"
  alertmanager = {
    resources = {
      alertmanager-image = "ubuntu/alertmanager@sha256:c7bb054a27fdad7412fcb401b1fde27598e4e65f1671d080f07b5fddfbe7d986"
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

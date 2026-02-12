# Refresh COS to a new channel

In this example, you will learn how to deploy COS Lite and refresh from channel `2/stable` to `2/edge`. To do this, we can deploy COS Lite via Terraform in the same way as [in the tutorial](https://documentation.ubuntu.com/observability/track-2/tutorial/installation/cos-lite-microk8s-sandbox).

## Prerequisites

This tutorial assumes that you already:

- Know how to deploy {ref}`COS Lite with Terraform <deploy-cos-ref>`

## Introduction

Imagine you have COS Lite (or COS) deployed on a specific channel like `2/stable` and want to
refresh to a different channel (or track) e.g., `2/edge`. To do so, an admin would have to manually
`juju refresh` each COS charm and address any refresh errors. Alternatively, they can determine the
correct charm `channel` and `revision`(s), update the Terraform module, and apply.

This is simplified within COS (and COS Lite) by mimicking the `juju refresh` behavior on a product
level, allowing the juju admin to specify a list of charms to refresh within the specified
`track/channel`. The rest is handled by Terraform.

## Update the COS Lite Terraform module

Once deployed, we can determine which charms to refresh with the `charms_to_refresh` input variable, detailed in the [README](https://github.com/canonical/observability-stack/tree/main/terraform/cos-lite). This defaults to: all charms owned by the `observability-team`.

```{note}
This tutorial assumed you have deployed COS Lite from a root module located at `./main.tf`.
```

Then, replace `2/stable` with `2/edge` in your `cos-lite` module within the existing `./main.tf` file:

```{literalinclude} /tutorial/installation/cos-lite-microk8s-sandbox.tf
---
language: hcl
start-after: "# before-cos"
---
```

```{note}
The `base` input variable for the `cos-lite` module is important if the `track/channel` deploys charms to a different base than the default, detailed in the [README](https://github.com/canonical/observability-stack/tree/main/terraform/cos-lite).
```

Finally, add the provider definitions into the same `./main.tf` file:

```hcl
terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}
```

At this point, you will have one `main.tf` file ready for deployment. Now you can plan these changes with:

```shell
terraform plan
```

and Terraform plans to update each charm to the latest revision in the `2/edge` channel:

```shell
Terraform used the selected providers to generate the following
execution plan. Resource actions are indicated with the following
symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # module.cos.module.alertmanager.juju_application.alertmanager will be updated in-place
  ~ resource "juju_application" "alertmanager" {

# snip ...

      ~ charm {
          ~ channel  = "2/stable" -> "2/edge"
            name     = "alertmanager-k8s"
          ~ revision = 191 -> 192
            # (1 unchanged attribute hidden)
        }

# snip ...

Plan: 0 to add, 5 to change, 0 to destroy.
```

and finally apply the changes with:

```shell
terraform apply
```

At this point, you will have successfully upgraded COS Lite from `2/stable` to `2/edge`!

## Refresh information

This tutorial only considers upgrading COS Lite. However, the `charmhub` module is product-agnostic
and can be used to refresh charms, and other products e.g., COS.

You can consult the follow release documentation for refresh compatibility:

- [how-to cross-track upgrade](/how-to/upgrade/)
- [release policy](/reference/release-policy/)
- [release notes](/reference/release-notes/)

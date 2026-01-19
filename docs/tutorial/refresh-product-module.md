# Refresh COS to a new channel

In this example, you will learn how to deploy COS Lite and refresh from channel `2/stable` to `2/edge`. To do this, we can deploy COS Lite via Terraform in the same way as [in the tutorial](https://documentation.ubuntu.com/observability/track-2/tutorial/installation/cos-lite-microk8s-sandbox).

## Prerequisites

This tutorial assumes that you already have the following:

- Deployed {ref}`COS Lite with Terraform <deploy-cos-ref>`

## Introduction

Imagine you have COS Lite (or COS) deployed on a specific channel like `2/stable` and want to
refresh to a different channel (or track) e.g., `2/edge`. To do so, an admin would have to manually
`juju refresh` each COS charm. Or they can determine the correct charm revisions, update the Terraform module, and apply.

This is simplified with the `charmhub` module, which allows the juju admin to specify a list of
COS charms to refresh within the specified `track/channel`. The rest is handled by Terraform.

## Update the COS Lite Terraform module

Once deployed, we can:

1. update the `cos-lite` module
2. determine which charms to refresh
3. add the `locals` and `charmhub` modules

```{note}
This tutorial assumed you have deployed COS Lite from a root module located at `./main.tf`.
```

First, update your `cos-lite` module, in the existing `./main.tf` file, with the updated content:

```{literalinclude} /tutorial/installation/cos-lite-microk8s-sandbox.tf
---
language: hcl
start-after: "# before-cos"
end-before: "# before-channel"
---
```

```diff
+ channel      = local.channel
+ alertmanager = { revision = module.charmhub["alertmanager"].charm_revision }
+ catalogue    = { revision = module.charmhub["catalogue"].charm_revision }
+ grafana      = { revision = module.charmhub["grafana"].charm_revision }
+ loki         = { revision = module.charmhub["loki"].charm_revision }
+ prometheus   = { revision = module.charmhub["prometheus"].charm_revision }
}
```

Then remove the `+` symbols; they are only used to highlight the changes to the `cos-lite` module.
Finally, add the feature components (required for upgrading the product) into the same `./main.tf` file:

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

locals {
  channel = "2/edge"
  base    = "ubuntu@24.04"

  charms = {
    alertmanager = "alertmanager-k8s"
    catalogue    = "catalogue-k8s"
    grafana      = "grafana-k8s"
    loki         = "loki-k8s"
    prometheus   = "prometheus-k8s"
  }
}

module "charmhub" {
  source   = "../charmhub"
  for_each = local.charms

  charm        = each.value
  channel      = local.channel
  base         = local.base
  architecture = "amd64"
}
```

At this point, you will have one `main.tf` file. Now you can plan these changes with:

```shell
terraform plan
```

you will notice that Terraform plans to update each charm to the latest revision in the `2/edge` channel:

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

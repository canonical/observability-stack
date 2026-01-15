# Upgrade COS to a new channel

In this example, you will learn how to deploy COS Lite and upgrade from channel `2/stable` to `2/edge`. To do this, we can deploy COS Lite via Terraform in the same way as [in the tutorial](https://documentation.ubuntu.com/observability/track-2/tutorial/installation/cos-lite-microk8s-sandbox).

## Prerequisites

This tutorial assumes that you already have the following:

- Deployed {ref}`COS Lite with Terraform <deploy-cos-ref>`

## Introduction

Imagine you have COS Lite (or COS) deployed on a specific channel like `2/stable` and want to
upgrade to a different channel or track e.g., `2/edge`. To do so, an admin would have to manually
`juju refresh` each COS charm, or specify the correct revision in the Terraform module and apply.

This is simplified with the `charmhubs` module, which allows the juju admin to specify a list of
COS charms to upgrade within the specified `track/channel`. The rest is handled by Terraform.

## Update the COS Lite Terraform module

Once deployed, we can add the `locals` definition and a `charmhubs` module:

```{note}
Copy all the Terraform blocks into one file and remove the `+` symbols.
They are only used to highlight the changes to the COS Lite Terraform module.
```

```{literalinclude} /tutorial/installation/cos-lite-microk8s-sandbox.tf
:lines: 1-7
```

```diff
+   http = {
+     source  = "hashicorp/http"
+     version = "~> 3.0"
+   }
```

```{literalinclude} /tutorial/installation/cos-lite-microk8s-sandbox.tf
:lines: 8-18, 20-21
```

```diff
+ channel      = local.channel
+ alertmanager = { revision = module.charmhubs["alertmanager"].charm_revision }
+ catalogue    = { revision = module.charmhubs["catalogue"].charm_revision }
+ grafana      = { revision = module.charmhubs["grafana"].charm_revision }
+ loki         = { revision = module.charmhubs["loki"].charm_revision }
+ prometheus   = { revision = module.charmhubs["prometheus"].charm_revision }
}

+locals {
+  channel = "2/edge"
+  base    = "ubuntu@24.04"
+
+  charms = {
+    alertmanager = "alertmanager-k8s"
+    catalogue    = "catalogue-k8s"
+    grafana      = "grafana-k8s"
+    loki         = "loki-k8s"
+    prometheus   = "prometheus-k8s"
+  }
+}

+module "charmhubs" {
+  source   = "../charmhub"
+  for_each = local.charms
+
+  charm        = each.value
+  channel      = local.channel
+  base         = local.base
+  architecture = "amd64"
+}
```

and apply these changes on top of the previous state with:

```shell
terraform -chdir=<MODULE_ROOT> apply
```

you will notice that Terraform updates each charm to the latest revision in the `2/edge` channel:

```shell
Terraform used the selected providers to generate the following
execution plan. Resource actions are indicated with the following
symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # module.cos.module.alertmanager.juju_application.alertmanager will be updated in-place
  ~ resource "juju_application" "alertmanager" {
        id                 = "23dae45b-db71-405b-8035-1bc57a6e6285:alertmanager"
      ~ machines           = [] -> (known after apply)
        name               = "alertmanager"
      ~ storage            = [
          - {
              - count = 1 -> null
              - label = "data-5" -> null
              - pool  = "kubernetes" -> null
              - size  = "1G" -> null
            },
        ] -> (known after apply)
        # (7 unchanged attributes hidden)

      ~ charm {
          ~ channel  = "2/stable" -> "2/edge"
            name     = "alertmanager-k8s"
          ~ revision = 191 -> 192
            # (1 unchanged attribute hidden)
        }
    }

# snip ...

Plan: 0 to add, 5 to change, 0 to destroy.
```

## Upgrade information

You can consult the follow release documentation for upgrade compatibility:

- [release-policy](/reference/release-policy/)
- [release-notes](/reference/release-notes/)

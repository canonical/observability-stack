---
myst:
 html_meta:
   description: "Upgrade instructions for Canonical Observability Stack. Migrate from different COS and COS Lite tracks safely."
---

# How to upgrade

This guide shows how to upgrade an existing COS deployment to a newer track.

Find the section that matches the upgrade path you need:

- [Migrate from COS 2 to COS 3.0](#migrate-from-cos-2-to-cos-30) (COS or COS Lite)
- [Migrate from COS Lite 1 to COS 2](#migrate-from-cos-lite-1-to-cos-2)
- [Migrate from COS Lite 1 to COS Lite 2](#migrate-from-cos-lite-1-to-cos-lite-2)

## COS 3.0

### Migrate from COS 2 to COS 3.0

These steps apply to both **COS 3.0** and **COS Lite 3.0**. Although COS and COS Lite are distinct products with separate Terraform modules and different component sets, the upgrade procedure is the same unless a step includes an *Applies to* note.

Choose the method that matches how you deployed COS:

- [Using Terraform](#using-terraform) (recommended)
- [Without Terraform](#without-terraform)

### Using Terraform

This is the recommended upgrade method.

Before you begin, review [How to configure COS for strict reproducibility](configure-strict-reproducibility.md) to understand how to upgrade with version pinning.

1. Set the channel input to `2/stable`, then apply:
    ```bash
    terraform apply
    ```
2. Refresh all charms to the latest revision on `2/stable`:
    1. Check [charmhub.io](https://charmhub.io/) for the latest revision on `2/stable` [per component](../../reference/cos-components/index.md).
    2. Pin all components to those revisions, then apply:
        ```bash
        terraform apply
        ```
3. Remove the revision pins.
4. Review the [breaking changes](https://documentation.ubuntu.com/observability/latest/release-notes/#breaking-changes) for the new track and update your inputs accordingly.
5. Update the Terraform module source ref to a [release tag](https://github.com/canonical/observability-stack/tags), for example `tf-cos-3.0.n`, then apply:
    ```bash
    terraform init -upgrade
    terraform apply
    ```
6. Apply again, repeating until no new resources are created:
    ```bash
    terraform apply
    ```

### Without Terraform

Use this method only if you have no Terraform state, for example if you deployed via the COS Lite Juju bundle. Otherwise, upgrade [using Terraform](#using-terraform).

1. Refresh all COS 2 charms to the latest revision on `2/stable`:
    ```bash
    juju refresh <charm-name> --channel 2/stable
    ```
2. Refresh each charm to its target track (`major.minor`) as listed in [COS components](../../reference/cos-components/index.md):
    ```bash
    juju refresh <charm-name> --channel major.minor/stable
    ```

```{warning}
There is a known issue when manually refreshing Grafana from track 2 to a later track, which can cause the application to enter an error state. Without Terraform, the only workaround is to redeploy the Grafana application and re-add its previous relations.
```

## COS 2

### Migrate from COS Lite 1 to COS 2

From a data perspective, the main difference between COS Lite and COS is that COS uses different charms for the logs and metrics backends:

- For metrics, [Prometheus](https://charmhub.io/prometheus-k8s) is replaced with [distributed Mimir](https://charmhub.io/mimir-coordinator-k8s).
- For logs, monolithic [Loki](https://charmhub.io/loki-k8s) is replaced with [distributed Loki](https://charmhub.io/loki-coordinator-k8s).

Migrating data from Prometheus to Mimir, or between different Loki charms, is complex and nuanced. For this reason, we recommend a retention-based phase-out instead.

#### Migrate via retention-based phase-out

1. Deploy COS in a separate model, alongside COS Lite.
2. Relate the new COS charms to the same applications that COS Lite is related to.
3. Wait for the COS Lite retention period to elapse.
4. Verify that the same data is available in both COS Lite and COS.
5. Decommission COS Lite.

### Migrate from COS Lite 1 to COS Lite 2

1. Refresh all COS Lite 1 charms to the latest revision on `1/stable`.
2. Refresh each charm to track `2/stable`.

---
myst:
 html_meta:
   description: "Upgrade instructions for Canonical Observability Stack. Migrate from different COS and COS Lite tracks safely."
---

# How to upgrade

This guide shows how to upgrade an existing COS deployment to a newer track.

Find the section that matches the upgrade path you need:

- [Migrate from COS 3.0 to COS 3.1](#migrate-from-cos-30-to-cos-31) (COS or COS Lite)
- [Migrate from COS 2 to COS 3.0](#migrate-from-cos-2-to-cos-30) (COS or COS Lite)
- [Migrate from COS Lite 1 to COS 2](#migrate-from-cos-lite-1-to-cos-2)
- [Migrate from COS Lite 1 to COS Lite 2](#migrate-from-cos-lite-1-to-cos-lite-2)

## COS 3.1

### Migrate from COS 3.0 to COS 3.1

These steps apply to both **COS 3.1** and **COS Lite 3.1**. COS 3.1 has no breaking changes, so the upgrade is a change of module reference: the module looks up the latest revision of each component on the track that 3.1 uses and upgrades the applications in place, without removing and re-deploying them.

COS 3.1 is a short-term release, so this upgrade is optional. If you need the longer support window, stay on the COS 3.0 LTS; see the [release policy](../../reference/release-policy.md) for the support windows of each release.

Unlike the [COS 2 to COS 3.0](#migrate-from-cos-2-to-cos-30) migration, you don't have to pin every component revision by hand. Since COS 3.0 the module resolves revisions per charm track, so it performs the cross-track upgrade for you.

1. Remove any per-component `revision` and `resources` pins from your configuration, so that each application runs the latest revision of its current track:

    ```hcl
    module "cos" {
      source = "git::https://github.com/canonical/observability-stack//terraform/cos?ref=tf-cos-3.0.n"
      # ... other inputs, with no per-component revision or resources pins ...
    }
    ```

    ```bash
    terraform apply
    ```

    This keeps the upgrade gap small: the refresh brings every application to the newest revision of its current track, so the track change that follows is a single step. If you keep your pins, refresh them to the latest revision on the current track and update them again once the applications are on 3.1, otherwise the pins hold the applications on 3.0.

2. Set the `risk` input explicitly to the risk level you want, for example `risk = "stable"`. The default risk level differs between releases, so relying on it can silently change the risk level of your charms during the upgrade.

3. Review the [release notes for COS 3.1](../../release-notes.md) and update your inputs accordingly.

4. Update the Terraform module source ref to a [release tag](https://github.com/canonical/observability-stack/tags) for your product, for example `tf-cos-3.1.n` for COS or `tf-cos-lite-3.1.n` for COS Lite:

    ```hcl
    module "cos" {
      source = "git::https://github.com/canonical/observability-stack//terraform/cos?ref=tf-cos-3.1.n"
      risk   = "stable"
      # ... other inputs ...
    }
    ```

    ```bash
    terraform init -upgrade
    terraform apply
    ```

5. Apply again, repeating until no new resources are created:

    ```bash
    terraform apply
    ```

6. Check that every application came back up on its 3.1 revision:

    ```bash
    juju status
    ```

#### What changes in this upgrade

| Component        | 3.0 track | 3.1 track | Applies to       |
| ---------------- | --------- | --------- | ---------------- |
| **Alertmanager** | 0.31      | 0.34      | COS and COS Lite |
| **Prometheus**   | 3.11      | 3.14      | COS Lite         |

All other components stay on the track they use in 3.0, so the upgrade only refreshes them to the latest revision of that track.

*Applies to: `cos-lite`.* COS Lite 3.1 also deploys an [OpenTelemetry Collector](https://charmhub.io/opentelemetry-collector-k8s), which COS Lite 3.0 does not. The upgrade adds it to the model; configure it with the new `opentelemetry_collector` input.

### Migrate from COS 3.0 to COS 3.1 without Terraform

Use this method only if you have no Terraform state. Otherwise, upgrade [using Terraform](#migrate-from-cos-30-to-cos-31).

1. Refresh every application to the track that 3.1 uses, as listed in [COS components](../../reference/cos-components/index.md):

    ```bash
    juju refresh <charm-name> --channel <track>/stable
    ```

    Only Alertmanager and, for COS Lite, Prometheus move to a different track; every other application stays on its 3.0 track and picks up its latest revision.

2. *Applies to: `cos-lite`.* If you want the OpenTelemetry Collector that COS Lite 3.1 adds, deploy and integrate it yourself:

    ```bash
    juju deploy opentelemetry-collector-k8s --channel 0.130/stable
    ```

## COS 3.0

### Migrate from COS 2 to COS 3.0

These steps apply to both **COS 3.0** and **COS Lite 3.0**. Although COS and COS Lite are distinct products with separate Terraform modules and different component sets, the upgrade procedure is the same unless a step includes an *Applies to* note.

Choose the method that matches how you deployed COS:

- [Using Terraform](#using-terraform) (recommended)
- [Without Terraform](#without-terraform)

### Using Terraform

This is the recommended upgrade method.

Before you begin, review [How to configure COS for strict reproducibility](configure-strict-reproducibility.md) to understand how to upgrade with version pinning.

1. Ensure the channel input is set to `2/stable` in your Terraform configuration, then apply:

    ```hcl
    module "cos" {
      source  = "git::https://github.com/canonical/observability-stack//terraform/cos?ref=track/2"
      channel = "2/stable"
      # ... other inputs ...
    }
    ```

    ```bash
    terraform apply
    ```

2. Refresh all charms to the latest revision on `2/stable`:
    1. Check [charmhub.io](https://charmhub.io/) for the latest revision on `2/stable` for each charm.
    2. Pin each component to its latest revision using the [Terraform variable mapping](../../reference/cos-components/index.md#terraform-variable-mapping), then apply:

        ```hcl
        alertmanager = {
          revision = "REVISION"
        }
        catalogue = {
          revision = "REVISION"
        }
        grafana = {
          revision = "REVISION"
        }
        loki_coordinator = {
          revision = "REVISION"
        }
        loki_worker = {
          revision = "REVISION"
        }
        mimir_coordinator = {
          revision = "REVISION"
        }
        mimir_worker = {
          revision = "REVISION"
        }
        s3_integrator = {
          revision = "REVISION"
        }
        ssc = {
          revision = "REVISION"
        }
        tempo_coordinator = {
          revision = "REVISION"
        }
        tempo_worker = {
          revision = "REVISION"
        }
        traefik = {
          revision = "REVISION"
        }
        ```

    ```bash
    terraform apply
    ```
3. Remove the revision pins.
4. Review the breaking changes for the new track and update your inputs accordingly. The breaking changes for each release are documented in that release's notes; see the [release policy](../../reference/release-policy.md) for links to each version.
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

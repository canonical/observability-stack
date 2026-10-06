---
myst:
 html_meta:
   description: "Upgrade instructions for Canonical Observability Stack. Migrate from different COS and COS Lite tracks safely."
---

# How to upgrade

This guide shows how to upgrade an existing COS 3.0 or COS Lite 3.0 deployment to COS 3.1. Each release documents one upgrade only, so if you are on an older release, follow the chain from the guide of the release you are on.

Find the section that matches the upgrade path you need:

- [Migrate from COS 3.0 to COS 3.1](#migrate-from-cos-30-to-cos-31) (COS or COS Lite)
- [Migrate from COS 2 to COS 3.0](https://documentation.ubuntu.com/observability/track-3.0/how-to/deploy-and-manage/upgrade/#migrate-from-cos-2-to-cos-3-0) (COS or COS Lite)
- [Migrate from COS Lite 1 to COS 2](https://documentation.ubuntu.com/observability/track-3.0/how-to/deploy-and-manage/upgrade/#migrate-from-cos-lite-1-to-cos-2)
- [Migrate from COS Lite 1 to COS Lite 2](https://documentation.ubuntu.com/observability/track-3.0/how-to/deploy-and-manage/upgrade/#migrate-from-cos-lite-1-to-cos-lite-2)

## COS 3.1

### Migrate from COS 3.0 to COS 3.1

These steps apply to both **COS 3.1** and **COS Lite 3.1**. COS 3.1 has no breaking changes, so the upgrade is a change of module reference: the module looks up the latest revision of each component on the track that 3.1 uses and upgrades the applications in place, without removing and re-deploying them.

COS 3.1 is a short-term release, so this upgrade is optional. If you need the longer support window, stay on the COS 3.0 LTS; see the [release policy](../../reference/release-policy.md) for the support windows of each release.

Unlike the [COS 2 to COS 3.0](https://documentation.ubuntu.com/observability/track-3.0/how-to/deploy-and-manage/upgrade/#migrate-from-cos-2-to-cos-3-0) migration, you don't have to pin every component revision by hand. Since COS 3.0 the module resolves revisions per charm track, so it performs the cross-track upgrade for you.

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

2. Set the `risk` input explicitly to the risk level you want, for example `risk = "stable"`.

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

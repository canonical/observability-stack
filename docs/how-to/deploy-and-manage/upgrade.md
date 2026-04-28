---
myst:
 html_meta:
   description: "Upgrade instructions for Canonical Observability Stack. Migrate from different COS and COS Lite tracks safely."
---

# How to upgrade

This guide shows how to upgrade an existing COS deployment to a newer track.

## COS 3
### Migrate from COS 2 to COS 3
Using Terraform:

1. Update the channel input to track 2/stable and then:
    ```bash
    terraform init -upgrade; terraform apply
    ```
2. Manually refresh all charms to the latest revision in 2/stable 
    ```bash
    juju refresh <charm-name> --channel 2/stable
    ```
3. Update the Terraform module source ref to tf-cos-3.0.0 and then:
    ```bash
    terraform init -upgrade; terraform apply
    ```
4. Once Terraform has applied all resources, apply again until no new resources are applied:
    ```bash
    terraform apply
    ```

### Migrate from COS Lite 2 to COS Lite 3
Using Terraform:

1. Update the channel input to track 2/stable and then:
    ```bash
    terraform init -upgrade; terraform apply
    ```
2. Manually refresh all charms to the latest revision in 2/stable 
    ```bash
    juju refresh <charm-name> --channel 2/stable
    ```
3. Update the Terraform module source ref to tf-cos-lite-3.0.0 and then:
    ```bash
    terraform init -upgrade; terraform apply
    ```
4. Once Terraform has applied all resources, apply again until no new resources are applied:
    ```bash
    terraform apply
    ```

Without Terraform:

1. Refresh all track 2 charms so they point to the latest revision on `2/stable`.
    ```bash
    juju refresh <charm-name> --channel 2/stable
    ```
2. Refresh each charm's track (`major.minor`) to the ones in the [release notes](https://documentation.ubuntu.com/observability/latest/release-notes/#cos-lite-components).
    ```bash
    juju refresh <charm-name> --channel major.minor/stable
    ```


## COS 2

### Migrate from COS Lite 1 to COS 2

The main differences between COS Lite and COS from data perspective 
are that COS uses different charms for the logs and metrics backends.
For metrics, [Prometheus](https://charmhub.io/prometheus-k8s) is replaced with [distributed Mimir](https://charmhub.io/mimir-coordinator-k8s). For logs, monolithic 
[Loki](https://charmhub.io/loki-k8s) is replaced with [distributed Loki](https://charmhub.io/loki-coordinator-k8s).

Migrating data from Prometheus to Mimir or from one charm revision of 
Loki to another is complex and nuanced. At this point, we recommend a 
retention-based phase-out.

#### Migration via retention-based phase-out

1. Deploy COS in a separate model next to COS Lite
2. Relate the new COS charms to the same applications COS Lite is related to.
3. Wait for the retention period to elapse for COS Lite.
4. Verify the same data is available both in COS Lite and in COS
5. Decommission COS Lite.

### Migrate from COS Lite 1 to COS Lite 2

1. Refresh all track 1 charms so they point to the latest revision on `1/stable`.
2. Refresh to track 2.

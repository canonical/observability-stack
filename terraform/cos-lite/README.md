# Terraform module for COS solution

<!-- BEGIN_TF_DOCS -->



<!-- END_TF_DOCS -->

This is a Terraform module facilitating the deployment of COS solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

The COS Lite solution consists of the following Terraform modules:
- [alertmanager-k8s](https://github.com/canonical/alertmanager-k8s-operator): Handles alerts sent by clients applications.
- [catalogue-k8s](https://github.com/canonical/catalogue-k8s-operator/tree/main/terraform): UI catalogue.
- [grafana-k8s](https://github.com/canonical/grafana-k8s-operator): Visualization, monitoring, and dashboards.
- [loki-k8s](https://github.com/canonical/loki-k8s-operator/tree/main/terraform): Backend for logs
- [prometheus-k8s](https://github.com/canonical/prometheus-k8s-operator/tree/main/terraform/): Backend for metrics
- [self-signed-certificates](https://github.com/canonical/self-signed-certificates-operator): certificates operator to secure traffic with TLS.
- [traefik](https://github.com/canonical/traefik-k8s-operator/tree/main/terraform): ingress.

## Requirements

This module requires a `juju` model to be available. Refer to the [usage section](#usage) below for more details.

## API

### Inputs

The module offers the following configurable inputs:

| Name | Type | Description | Default |
|--|--|--|--|
| `channel` | string | Channel that all the charms (unless overwritten) are deployed from |
| `model` | string | Reference to an existing model resource or data source for the model to deploy to |
| `use_tls` | bool   | Specify whether to use TLS or not for coordinator-worker communication | true |

### Outputs

Upon application, the module exports the following outputs:

| Name       | Description                 |
|------------|-----------------------------|
| `app_name` | Application name            |
| `provides` | Map of `provides` endpoints |
| `requires` | Map of `requires` endpoints |

## Usage


### Basic usage

Users should ensure that Terraform is aware of the `juju_model` dependency of the charm module.

To deploy this module with its needed dependency, you can run `terraform apply -var="model=<MODEL_NAME>" -auto-approve`. This would deploy all COS HA solution modules in the same model.


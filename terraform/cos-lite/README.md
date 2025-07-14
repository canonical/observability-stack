# Terraform module for COS solution

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | >= 0.20.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alertmanager_revision"></a> [alertmanager\_revision](#input\_alertmanager\_revision) | Revision number of the Alertmanager charm | `number` | `null` | no |
| <a name="input_catalogue_revision"></a> [catalogue\_revision](#input\_catalogue\_revision) | Revision number of the Catalogue charm | `number` | `null` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | Channel that the charms are (unless overwritten by external\_channels) deployed from | `string` | n/a | yes |
| <a name="input_external_certificates_offer_url"></a> [external\_certificates\_offer\_url](#input\_external\_certificates\_offer\_url) | A Juju offer URL (e.g. admin/external-ca.certificates) of a CA providing the 'tls\_certificates' integration for Traefik to supply it with server certificates. | `string` | `null` | no |
| <a name="input_grafana_revision"></a> [grafana\_revision](#input\_grafana\_revision) | Revision number of the Grafana charm | `number` | `null` | no |
| <a name="input_internal_tls"></a> [internal\_tls](#input\_internal\_tls) | Specify whether to use TLS or not for internal COS communication. By default, TLS is enabled using self-signed-certificates | `bool` | `true` | no |
| <a name="input_loki_revision"></a> [loki\_revision](#input\_loki\_revision) | Revision number of the Loki charm | `number` | `null` | no |
| <a name="input_model"></a> [model](#input\_model) | Reference to an existing model resource or data source for the model to deploy to | `string` | n/a | yes |
| <a name="input_prometheus_revision"></a> [prometheus\_revision](#input\_prometheus\_revision) | Revision number of the Prometheus charm | `number` | `null` | no |
| <a name="input_ssc_channel"></a> [ssc\_channel](#input\_ssc\_channel) | Channel that the self-signed certificates charm is deployed from | `string` | `"1/stable"` | no |
| <a name="input_ssc_revision"></a> [ssc\_revision](#input\_ssc\_revision) | Revision number of the self-signed certificates charm | `number` | `null` | no |
| <a name="input_traefik_channel"></a> [traefik\_channel](#input\_traefik\_channel) | Channel that the Traefik charm is deployed from | `string` | `"latest/stable"` | no |
| <a name="input_traefik_revision"></a> [traefik\_revision](#input\_traefik\_revision) | Revision number of the Traefik charm | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_components"></a> [components](#output\_components) | All Terraform charm modules which make up this product module |
| <a name="output_offers"></a> [offers](#output\_offers) | All Juju offers which are exposed by this product module |
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


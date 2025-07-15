# Terraform module for COS solution

This is a Terraform module facilitating the deployment of COS solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | >= 0.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | 0.20.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alertmanager"></a> [alertmanager](#module\_alertmanager) | git::https://github.com/canonical/alertmanager-k8s-operator//terraform | n/a |
| <a name="module_catalogue"></a> [catalogue](#module\_catalogue) | git::https://github.com/canonical/catalogue-k8s-operator//terraform | n/a |
| <a name="module_grafana"></a> [grafana](#module\_grafana) | git::https://github.com/canonical/grafana-k8s-operator//terraform | n/a |
| <a name="module_loki"></a> [loki](#module\_loki) | git::https://github.com/canonical/loki-k8s-operator//terraform | n/a |
| <a name="module_prometheus"></a> [prometheus](#module\_prometheus) | git::https://github.com/canonical/prometheus-k8s-operator//terraform | n/a |
| <a name="module_ssc"></a> [ssc](#module\_ssc) | git::https://github.com/canonical/self-signed-certificates-operator//terraform | n/a |
| <a name="module_traefik"></a> [traefik](#module\_traefik) | git::https://github.com/canonical/traefik-k8s-operator//terraform | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alertmanager_config"></a> [alertmanager\_config](#input\_alertmanager\_config) | Map of the Alertmanager configuration options | `map(string)` | `{}` | no |
| <a name="input_alertmanager_constraints"></a> [alertmanager\_constraints](#input\_alertmanager\_constraints) | String listing constraints for the Alertmanager application | `string` | `"arch=amd64"` | no |
| <a name="input_alertmanager_revision"></a> [alertmanager\_revision](#input\_alertmanager\_revision) | Revision number of the Alertmanager application | `number` | `null` | no |
| <a name="input_alertmanager_storage_directives"></a> [alertmanager\_storage\_directives](#input\_alertmanager\_storage\_directives) | Map of storage used by the Alertmanager application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_alertmanager_units"></a> [alertmanager\_units](#input\_alertmanager\_units) | Unit count/scale of the Alertmanager application | `number` | `1` | no |
| <a name="input_catalogue_config"></a> [catalogue\_config](#input\_catalogue\_config) | Map of the Catalogue configuration options | `map(string)` | `{}` | no |
| <a name="input_catalogue_constraints"></a> [catalogue\_constraints](#input\_catalogue\_constraints) | String listing constraints for the Catalogue application | `string` | `"arch=amd64"` | no |
| <a name="input_catalogue_revision"></a> [catalogue\_revision](#input\_catalogue\_revision) | Revision number of the Catalogue application | `number` | `null` | no |
| <a name="input_catalogue_storage_directives"></a> [catalogue\_storage\_directives](#input\_catalogue\_storage\_directives) | Map of storage used by the Catalogue application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_catalogue_units"></a> [catalogue\_units](#input\_catalogue\_units) | Unit count/scale of the Catalogue application | `number` | `1` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | Channel that the applications are (unless overwritten by external\_channels) deployed from | `string` | n/a | yes |
| <a name="input_external_certificates_offer_url"></a> [external\_certificates\_offer\_url](#input\_external\_certificates\_offer\_url) | A Juju offer URL (e.g. admin/external-ca.certificates) of a CA providing the 'tls\_certificates' integration for Traefik to supply it with server certificates. | `string` | `null` | no |
| <a name="input_grafana_config"></a> [grafana\_config](#input\_grafana\_config) | Map of the Grafana configuration options | `map(string)` | `{}` | no |
| <a name="input_grafana_constraints"></a> [grafana\_constraints](#input\_grafana\_constraints) | String listing constraints for the Grafana application | `string` | `"arch=amd64"` | no |
| <a name="input_grafana_revision"></a> [grafana\_revision](#input\_grafana\_revision) | Revision number of the Grafana application | `number` | `null` | no |
| <a name="input_grafana_storage_directives"></a> [grafana\_storage\_directives](#input\_grafana\_storage\_directives) | Map of storage used by the Grafana application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_grafana_units"></a> [grafana\_units](#input\_grafana\_units) | Unit count/scale of the Grafana application | `number` | `1` | no |
| <a name="input_internal_tls"></a> [internal\_tls](#input\_internal\_tls) | Specify whether to use TLS or not for internal COS communication. By default, TLS is enabled using self-signed-certificates | `bool` | `true` | no |
| <a name="input_loki_config"></a> [loki\_config](#input\_loki\_config) | Map of the Loki configuration options | `map(string)` | `{}` | no |
| <a name="input_loki_constraints"></a> [loki\_constraints](#input\_loki\_constraints) | String listing constraints for the Loki application | `string` | `"arch=amd64"` | no |
| <a name="input_loki_revision"></a> [loki\_revision](#input\_loki\_revision) | Revision number of the Loki application | `number` | `null` | no |
| <a name="input_loki_units"></a> [loki\_units](#input\_loki\_units) | Unit count/scale of the Loki application | `number` | `1` | no |
| <a name="input_model"></a> [model](#input\_model) | Reference to an existing model resource or data source for the model to deploy to | `string` | n/a | yes |
| <a name="input_prometheus_config"></a> [prometheus\_config](#input\_prometheus\_config) | Map of the Prometheus configuration options | `map(string)` | `{}` | no |
| <a name="input_prometheus_constraints"></a> [prometheus\_constraints](#input\_prometheus\_constraints) | String listing constraints for the Prometheus application | `string` | `"arch=amd64"` | no |
| <a name="input_prometheus_revision"></a> [prometheus\_revision](#input\_prometheus\_revision) | Revision number of the Prometheus application | `number` | `null` | no |
| <a name="input_prometheus_storage_directives"></a> [prometheus\_storage\_directives](#input\_prometheus\_storage\_directives) | Map of storage used by the Prometheus application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_prometheus_units"></a> [prometheus\_units](#input\_prometheus\_units) | Unit count/scale of the Prometheus application | `number` | `1` | no |
| <a name="input_ssc_channel"></a> [ssc\_channel](#input\_ssc\_channel) | Channel that the self-signed certificates application is deployed from | `string` | `"1/stable"` | no |
| <a name="input_ssc_config"></a> [ssc\_config](#input\_ssc\_config) | Map of the self-signed certificates configuration options | `map(string)` | `{}` | no |
| <a name="input_ssc_constraints"></a> [ssc\_constraints](#input\_ssc\_constraints) | String listing constraints for the self-signed certificates application | `string` | `"arch=amd64"` | no |
| <a name="input_ssc_revision"></a> [ssc\_revision](#input\_ssc\_revision) | Revision number of the self-signed certificates application | `number` | `null` | no |
| <a name="input_ssc_units"></a> [ssc\_units](#input\_ssc\_units) | Unit count/scale of the self-signed certificates application | `number` | `1` | no |
| <a name="input_traefik_channel"></a> [traefik\_channel](#input\_traefik\_channel) | Channel that the Traefik application is deployed from | `string` | `"latest/stable"` | no |
| <a name="input_traefik_config"></a> [traefik\_config](#input\_traefik\_config) | Map of the Traefik configuration options | `map(string)` | `{}` | no |
| <a name="input_traefik_constraints"></a> [traefik\_constraints](#input\_traefik\_constraints) | String listing constraints for the Traefik application | `string` | `"arch=amd64"` | no |
| <a name="input_traefik_revision"></a> [traefik\_revision](#input\_traefik\_revision) | Revision number of the Traefik application | `number` | `null` | no |
| <a name="input_traefik_storage_directives"></a> [traefik\_storage\_directives](#input\_traefik\_storage\_directives) | Map of storage used by the Traefik application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_traefik_units"></a> [traefik\_units](#input\_traefik\_units) | Unit count/scale of the Traefik application | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_components"></a> [components](#output\_components) | All Terraform charm modules which make up this product module |
| <a name="output_offers"></a> [offers](#output\_offers) | All Juju offers which are exposed by this product module |
<!-- END_TF_DOCS -->

## Usage

### Basic usage

Users should ensure that Terraform is aware of the `juju_model` dependency of the charm module.

To deploy this module with its needed dependency, you can run `terraform apply -var="model=<MODEL_NAME>" -auto-approve`. This would deploy all COS HA solution modules in the same model.

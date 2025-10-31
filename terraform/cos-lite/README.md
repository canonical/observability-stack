# Terraform module for the COS Lite solution

This is a Terraform module facilitating the deployment of the COS Lite solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | ~> 1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alertmanager"></a> [alertmanager](#module\_alertmanager) | git::https://github.com/canonical/alertmanager-k8s-operator//terraform | tf-provider-v0 |
| <a name="module_catalogue"></a> [catalogue](#module\_catalogue) | git::https://github.com/canonical/catalogue-k8s-operator//terraform | tf-provider-v0 |
| <a name="module_grafana"></a> [grafana](#module\_grafana) | git::https://github.com/canonical/grafana-k8s-operator//terraform | tf-provider-v0 |
| <a name="module_loki"></a> [loki](#module\_loki) | git::https://github.com/canonical/loki-k8s-operator//terraform | tf-provider-v0 |
| <a name="module_prometheus"></a> [prometheus](#module\_prometheus) | git::https://github.com/canonical/prometheus-k8s-operator//terraform | tf-provider-v0 |
| <a name="module_ssc"></a> [ssc](#module\_ssc) | git::https://github.com/canonical/self-signed-certificates-operator//terraform | n/a |
| <a name="module_traefik"></a> [traefik](#module\_traefik) | git::https://github.com/canonical/traefik-k8s-operator//terraform | a8a0da68b9aa8e30e6ad00eac7aa552bcd88a8ef |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alertmanager"></a> [alertmanager](#input\_alertmanager) | Application configuration for Alertmanager. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "alertmanager")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_catalogue"></a> [catalogue](#input\_catalogue) | Application configuration for Catalogue. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "catalogue")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | Channel that the applications are (unless overwritten by external\_channels) deployed from | `string` | n/a | yes |
| <a name="input_external_certificates_offer_url"></a> [external\_certificates\_offer\_url](#input\_external\_certificates\_offer\_url) | A Juju offer URL (e.g. admin/external-ca.certificates) of a CA providing the 'tls\_certificates' integration for Traefik to supply it with server certificates. | `string` | `null` | no |
| <a name="input_grafana"></a> [grafana](#input\_grafana) | Application configuration for Grafana. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "grafana")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_internal_tls"></a> [internal\_tls](#input\_internal\_tls) | Specify whether to use TLS or not for internal COS communication. By default, TLS is enabled using self-signed-certificates | `bool` | `true` | no |
| <a name="input_loki"></a> [loki](#input\_loki) | Application configuration for Loki. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "loki")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_model_uuid"></a> [model\_uuid](#input\_model\_uuid) | Reference to an existing model resource or data source for the model to deploy to | `string` | n/a | yes |
| <a name="input_prometheus"></a> [prometheus](#input\_prometheus) | Application configuration for Prometheus. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "prometheus")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_ssc"></a> [ssc](#input\_ssc) | Application configuration for self-signed-certificates. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "ca")<br/>    channel            = optional(string, "1/stable")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_traefik"></a> [traefik](#input\_traefik) | Application configuration for Traefik. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "traefik")<br/>    channel            = optional(string, "latest/stable")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_components"></a> [components](#output\_components) | All Terraform charm modules which make up this product module |
| <a name="output_offers"></a> [offers](#output\_offers) | All Juju offers which are exposed by this product module |
<!-- END_TF_DOCS -->

## Usage

### Using different Terraform Juju provider versions
If you require the Terraform Juju provider `< 1.0.0`, then deploy the COS Lite module with the `tf-provider-v0` tag:

```hcl
module "cos-lite" {
  source     = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=tf-provider-v0"
}
```

Otherwise, you can deploy from main (without `?ref`) which uses the Terraform Juju provider `~> 1.0`. See the [v1 migration documentation](https://documentation.ubuntu.com/terraform-provider-juju/v1/howto/manage-provider/upgrade-provider-to-v1/) if you need to upgrade your modules.

### Basic usage

To deploy the COS HA solution in a model named `cos`, create this root module:
```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

data "juju_model" "my-model" {
  name  = "cos"
  owner = "admin"
}

module "cos-lite" {
  source     = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model_uuid = data.juju_model.my-model.uuid
  channel    = "2/edge"
}
```

Then, use terraform to deploy the module:

```shell
terraform init
terraform apply
```

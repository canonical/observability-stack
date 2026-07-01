# Terraform module for the COS Lite solution

This is a Terraform module facilitating the deployment of the COS Lite solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | >= 1.4.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alertmanager"></a> [alertmanager](#module\_alertmanager) | git::https://github.com/canonical/alertmanager-k8s-operator//terraform | tf-0.31.0 |
| <a name="module_catalogue"></a> [catalogue](#module\_catalogue) | git::https://github.com/canonical/catalogue-k8s-operator//terraform | tf-3.0.0 |
| <a name="module_grafana"></a> [grafana](#module\_grafana) | git::https://github.com/canonical/grafana-k8s-operator//terraform | tf-12.4.0 |
| <a name="module_loki"></a> [loki](#module\_loki) | git::https://github.com/canonical/loki-k8s-operator//terraform | tf-3.7.0 |
| <a name="module_prometheus"></a> [prometheus](#module\_prometheus) | git::https://github.com/canonical/prometheus-k8s-operator//terraform | tf-3.11.0 |
| <a name="module_ssc"></a> [ssc](#module\_ssc) | git::https://github.com/canonical/self-signed-certificates-operator//terraform | rev653 |
| <a name="module_traefik"></a> [traefik](#module\_traefik) | git::https://github.com/canonical/traefik-k8s-operator//terraform | rev301 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alertmanager"></a> [alertmanager](#input\_alertmanager) | Application configuration for Alertmanager. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "alertmanager")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_base"></a> [base](#input\_base) | The operating system on which to deploy. E.g. ubuntu@24.04. Check Charmhub for per-charm base support. | `string` | `"ubuntu@26.04"` | no |
| <a name="input_catalogue"></a> [catalogue](#input\_catalogue) | Application configuration for Catalogue. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "catalogue")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_external_ca_cert_offer_url"></a> [external\_ca\_cert\_offer\_url](#input\_external\_ca\_cert\_offer\_url) | A Juju offer URL (e.g. admin/external-ca.send-ca-cert) of a CA providing the 'certificate\_transfer' integration for applications to trust ingress via Traefik. | `string` | `null` | no |
| <a name="input_external_certificates_offer_url"></a> [external\_certificates\_offer\_url](#input\_external\_certificates\_offer\_url) | A Juju offer URL (e.g. admin/external-ca.certificates) of a CA providing the 'tls\_certificates' integration for Traefik to supply it with server certificates. | `string` | `null` | no |
| <a name="input_grafana"></a> [grafana](#input\_grafana) | Application configuration for Grafana. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "grafana")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    resources          = optional(map(string), {})<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Per-component toggle for ingress integrations | <pre>object({<br/>    alertmanager = optional(bool, true)<br/>    catalogue    = optional(bool, true)<br/>    grafana      = optional(bool, true)<br/>    loki         = optional(bool, true)<br/>    prometheus   = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_internal_tls"></a> [internal\_tls](#input\_internal\_tls) | Specify whether to use TLS or not for internal COS communication. By default, TLS is enabled using self-signed-certificates | `bool` | `true` | no |
| <a name="input_loki"></a> [loki](#input\_loki) | Application configuration for Loki. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "loki")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    resources          = optional(map(string), {})<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_model"></a> [model](#input\_model) | Model configuration. When `uuid` is set, an existing model is looked up; otherwise a new model is created with the given fields. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/model | <pre>object({<br/>    uuid = optional(string)<br/>    name = optional(string, "cos-lite")<br/>    cloud = optional(object({<br/>      name   = string<br/>      region = optional(string)<br/>    }))<br/>    annotations       = optional(map(string))<br/>    config            = optional(map(string))<br/>    constraints       = optional(string)<br/>    credential        = optional(string)<br/>    target_controller = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_postgresql_offer_url"></a> [postgresql\_offer\_url](#input\_postgresql\_offer\_url) | A Juju offer URL (e.g. admin/postgresql.database) of a PostgreSQL service providing the 'postgresql\_client' integration for applications to connect to the database. | `string` | `null` | no |
| <a name="input_prometheus"></a> [prometheus](#input\_prometheus) | Application configuration for Prometheus. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "prometheus")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    resources          = optional(map(string), {})<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_risk"></a> [risk](#input\_risk) | Risk level that the applications are (unless overwritten by individual channels) deployed from | `string` | `"edge"` | no |
| <a name="input_ssc"></a> [ssc](#input\_ssc) | Application configuration for self-signed-certificates. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "ca")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_traefik"></a> [traefik](#input\_traefik) | Application configuration for Traefik. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "traefik")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    resources          = optional(map(string), {})<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_components"></a> [components](#output\_components) | All Terraform charm modules which make up this product module |
| <a name="output_model_uuid"></a> [model\_uuid](#output\_model\_uuid) | The UUID of the model (created or looked up) |
| <a name="output_offers"></a> [offers](#output\_offers) | All Juju offers which are exposed by this product module |
<!-- END_TF_DOCS -->

## Usage

### Using different Terraform Juju provider versions

#### Provider v0
If you require the Terraform Juju provider `< 1.0.0`, then deploy the COS module with the `tf-provider-v0` tag:

```hcl
module "cos-lite" {
  source = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=tf-provider-v0"
  # ... and other required variables ...
}
```

Otherwise, you can deploy from main (without `?ref`) which supports the v1 Terraform Juju provider. See the [v1 migration documentation](https://documentation.ubuntu.com/terraform-provider-juju/v1/howto/manage-provider/upgrade-provider-to-v1/) if you need to upgrade your modules.

#### Provider >= 1.0.0, < 1.4.0
If you require the Terraform Juju provider `< 1.4.0`, then deploy the COS module from the [c1c8bd9](https://github.com/canonical/observability-stack/commit/c1c8bd9a17abe079242eb9535c6b7a4fa8832a02) commit hash:

```hcl
module "cos-lite" {
  source = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=c1c8bd9a17abe079242eb9535c6b7a4fa8832a02"
  # ... and other required variables ...
}
```

### Basic usage

The minimum version of Terraform Juju provider required is `1.5`.

To deploy the COS Lite solution in a model named `cos-lite`, create this root module:
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

module "cos-lite" {
  source = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
}
```

Then, use terraform to deploy the module:

```shell
terraform init
terraform apply
```

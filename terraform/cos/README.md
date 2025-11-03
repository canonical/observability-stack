# Terraform module for the COS solution

This is a Terraform module facilitating the deployment of the COS solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs). This Terraform module deploys COS with Mimir, Tempo and Loki in their microservices modes, and other charms in monolithic mode.

> [!NOTE]
> `s3-integrator` itself doesn't act as an S3 object storage system. For the HA solution to be functional, `s3-integrator` needs to point to an S3-like storage. See [this guide](https://documentation.ubuntu.com/observability/latest/tutorial/installation/cos-canonical-k8s-sandbox/#set-up-s3) to learn how to connect to an S3-like storage. If you deploy the COS TF module with an s3-integrator from `channel=2/edge` and `>=rev243`, then the buckets are automatically created for you.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | ~> 1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alertmanager"></a> [alertmanager](#module\_alertmanager) | git::https://github.com/canonical/alertmanager-k8s-operator//terraform | n/a |
| <a name="module_catalogue"></a> [catalogue](#module\_catalogue) | git::https://github.com/canonical/catalogue-k8s-operator//terraform | n/a |
| <a name="module_grafana"></a> [grafana](#module\_grafana) | git::https://github.com/canonical/grafana-k8s-operator//terraform | n/a |
| <a name="module_loki"></a> [loki](#module\_loki) | git::https://github.com/canonical/observability-stack//terraform/loki | n/a |
| <a name="module_mimir"></a> [mimir](#module\_mimir) | git::https://github.com/canonical/observability-stack//terraform/mimir | n/a |
| <a name="module_opentelemetry_collector"></a> [opentelemetry\_collector](#module\_opentelemetry\_collector) | git::https://github.com/canonical/opentelemetry-collector-k8s-operator//terraform | n/a |
| <a name="module_ssc"></a> [ssc](#module\_ssc) | git::https://github.com/canonical/self-signed-certificates-operator//terraform | n/a |
| <a name="module_tempo"></a> [tempo](#module\_tempo) | git::https://github.com/canonical/tempo-operators//terraform | n/a |
| <a name="module_traefik"></a> [traefik](#module\_traefik) | git::https://github.com/canonical/traefik-k8s-operator//terraform | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alertmanager"></a> [alertmanager](#input\_alertmanager) | Application configuration for Alertmanager. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "alertmanager")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_anti_affinity"></a> [anti\_affinity](#input\_anti\_affinity) | Enable anti-affinity constraints across all HA modules (Mimir, Loki, Tempo) | `bool` | `true` | no |
| <a name="input_catalogue"></a> [catalogue](#input\_catalogue) | Application configuration for Catalogue. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "catalogue")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | Channel that the applications are (unless overwritten by external\_channels) deployed from | `string` | n/a | yes |
| <a name="input_cloud"></a> [cloud](#input\_cloud) | Kubernetes cloud or environment where this COS module will be deployed (e.g self-managed, aws) | `string` | `"self-managed"` | no |
| <a name="input_external_certificates_offer_url"></a> [external\_certificates\_offer\_url](#input\_external\_certificates\_offer\_url) | A Juju offer URL of a CA providing the 'tls\_certificates' integration for Traefik to supply it with server certificates | `string` | `null` | no |
| <a name="input_grafana"></a> [grafana](#input\_grafana) | Application configuration for Grafana. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "grafana")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_internal_tls"></a> [internal\_tls](#input\_internal\_tls) | Specify whether to use TLS or not for internal COS communication. By default, TLS is enabled using self-signed-certificates | `bool` | `true` | no |
| <a name="input_loki_bucket"></a> [loki\_bucket](#input\_loki\_bucket) | Loki bucket name | `string` | `"loki"` | no |
| <a name="input_loki_coordinator"></a> [loki\_coordinator](#input\_loki\_coordinator) | Application configuration for Loki Coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 3)<br/>  })</pre> | `{}` | no |
| <a name="input_loki_worker"></a> [loki\_worker](#input\_loki\_worker) | Application configuration for all Loki Workers. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    backend_config     = optional(map(string), {})<br/>    read_config        = optional(map(string), {})<br/>    write_config       = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    backend_units      = optional(number, 3)<br/>    read_units         = optional(number, 3)<br/>    write_units        = optional(number, 3)<br/>  })</pre> | `{}` | no |
| <a name="input_mimir_bucket"></a> [mimir\_bucket](#input\_mimir\_bucket) | Mimir bucket name | `string` | `"mimir"` | no |
| <a name="input_mimir_coordinator"></a> [mimir\_coordinator](#input\_mimir\_coordinator) | Application configuration for Mimir Coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 3)<br/>  })</pre> | `{}` | no |
| <a name="input_mimir_worker"></a> [mimir\_worker](#input\_mimir\_worker) | Application configuration for all Mimir Workers. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    backend_config     = optional(map(string), {})<br/>    read_config        = optional(map(string), {})<br/>    write_config       = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    backend_units      = optional(number, 3)<br/>    read_units         = optional(number, 3)<br/>    write_units        = optional(number, 3)<br/>  })</pre> | `{}` | no |
| <a name="input_model_uuid"></a> [model\_uuid](#input\_model\_uuid) | Reference to an existing model resource or data source for the model to deploy to | `string` | n/a | yes |
| <a name="input_opentelemetry_collector"></a> [opentelemetry\_collector](#input\_opentelemetry\_collector) | Application configuration for OpenTelemetry Collector. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "otelcol")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_s3_access_key"></a> [s3\_access\_key](#input\_s3\_access\_key) | S3 access-key credential | `string` | n/a | yes |
| <a name="input_s3_endpoint"></a> [s3\_endpoint](#input\_s3\_endpoint) | S3 endpoint | `string` | n/a | yes |
| <a name="input_s3_integrator"></a> [s3\_integrator](#input\_s3\_integrator) | Application configuration for all S3-integrators in coordinated workers. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    channel            = optional(string, "2/edge")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_s3_secret_key"></a> [s3\_secret\_key](#input\_s3\_secret\_key) | S3 secret-key credential | `string` | n/a | yes |
| <a name="input_ssc"></a> [ssc](#input\_ssc) | Application configuration for Self-signed-certificates. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "ca")<br/>    channel            = optional(string, "1/stable")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_tempo_bucket"></a> [tempo\_bucket](#input\_tempo\_bucket) | Tempo bucket name | `string` | `"tempo"` | no |
| <a name="input_tempo_coordinator"></a> [tempo\_coordinator](#input\_tempo\_coordinator) | Application configuration for Tempo Coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 3)<br/>  })</pre> | `{}` | no |
| <a name="input_tempo_worker"></a> [tempo\_worker](#input\_tempo\_worker) | Application configuration for all Tempo workers. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    querier_config           = optional(map(string), {})<br/>    query_frontend_config    = optional(map(string), {})<br/>    ingester_config          = optional(map(string), {})<br/>    distributor_config       = optional(map(string), {})<br/>    compactor_config         = optional(map(string), {})<br/>    metrics_generator_config = optional(map(string), {})<br/>    constraints              = optional(string, "arch=amd64")<br/>    revision                 = optional(number, null)<br/>    storage_directives       = optional(map(string), {})<br/>    compactor_units          = optional(number, 3)<br/>    distributor_units        = optional(number, 3)<br/>    ingester_units           = optional(number, 3)<br/>    metrics_generator_units  = optional(number, 3)<br/>    querier_units            = optional(number, 3)<br/>    query_frontend_units     = optional(number, 3)<br/>  })</pre> | `{}` | no |
| <a name="input_traefik"></a> [traefik](#input\_traefik) | Application configuration for Traefik. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "traefik")<br/>    channel            = optional(string, "latest/stable")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_components"></a> [components](#output\_components) | All Terraform charm modules which make up this product module |
| <a name="output_offers"></a> [offers](#output\_offers) | All Juju offers which are exposed by this product module |
<!-- END_TF_DOCS -->

## Usage

### Using different Terraform Juju provider versions
If you require the Terraform Juju provider `< 1.0.0`, then deploy the COS module with the `tf-provider-v0` tag:

```hcl
module "cos" {
  source     = "git::https://github.com/canonical/observability-stack//terraform/cos?ref=tf-provider-v0"
}
```

Otherwise, you can deploy from main (without `?ref`) which uses the Terraform Juju provider `~> 1.0`. See the [v1 migration documentation](https://documentation.ubuntu.com/terraform-provider-juju/v1/howto/manage-provider/upgrade-provider-to-v1/) if you need to upgrade your modules.

### Basic usage

By default, this Terraform module will deploy each worker with `3` unit. If you want to scale each Loki, Mimir or Tempo worker unit please check the variables available for that purpose in `variables.tf`.

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

module "cos" {
  source     = "git::https://github.com/canonical/observability-stack//terraform/cos"
  model_uuid = data.juju_model.my-model.uuid
  channel    = "2/edge"

  s3_endpoint   = "http://S3_HOST_IP:8080"
  s3_secret_key = "secret-key"
  s3_access_key = "access-key"
}
```

Then, use terraform to deploy the module:

```shell
terraform init
terraform apply
```

#### Known Juju issue.

This [Juju issue](https://github.com/juju/juju/issues/20210) exists on Juju `< 3.6.11` where you may see a message like this one, after running `terraform apply`:

```
╷
│ Error: Client Error
│ 
│   with module.cos.module.mimir.juju_secret.mimir_s3_credentials_secret,
│   on /home/mt/work/canonical/repos/observability/terraform/modules/mimir/main.tf line 1, in resource "juju_secret" "mimir_s3_credentials_secret":
│    1: resource "juju_secret" "mimir_s3_credentials_secret" {
│ 
│ Unable to add secret, got error: rolebindings.rbac.authorization.k8s.io "model-cos"
│ already exists
╵
```

If you are forced to use Juju `< 3.6.11`, a workaround to this is to retry `terraform apply` a few times. Otherwise, create a fresh Juju controller with version `>= 3.6.11`

### Deploy COS on AWS EKS

> **Note:** This deployment assumes that the required AWS infrastructure is already provisioned and that a Juju controller has been bootstrapped.  
> Additionally, a Juju model must be ready in advance.
> 
> See [provision AWS infrastructure](../aws-infra/README.md)

In order to deploy COS on AWS, update the `cloud` input of the `cos` module to `aws` and any S3 storage configurations:

```hcl
module "cos" {
  source     = "git::https://github.com/canonical/observability-stack//terraform/cos"
  model_uuid = data.juju_model.my-model.uuid
  channel    = "2/edge"
  cloud      = "aws"

  s3_endpoint   = "http://S3_HOST_IP:8080"
  s3_secret_key = "secret-key"
  s3_access_key = "access-key"
}
```

Then, use terraform to deploy the module:
```bash
terraform init
terraform apply
```

# Terraform module for the COS Dev solution

This is a Terraform module facilitating the deployment of the COS Dev solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs). This Terraform module deploys a lightweight COS stack supporting both **monolithic** and **distributed** topologies, and either [SeaweedFS](https://github.com/seaweedfs/seaweedfs) or an external S3-compatible store (via `s3-integrator`) as the storage backend.

This module is intended for development and testing environments where full HA is not required. It uses the individual coordinator and worker charm modules, rather than the bundled operator modules used by the main COS module.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | ~> 1.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alertmanager"></a> [alertmanager](#module\_alertmanager) | git::https://github.com/canonical/alertmanager-k8s-operator//terraform | n/a |
| <a name="module_catalogue"></a> [catalogue](#module\_catalogue) | git::https://github.com/canonical/catalogue-k8s-operator//terraform | n/a |
| <a name="module_grafana"></a> [grafana](#module\_grafana) | git::https://github.com/canonical/grafana-k8s-operator//terraform | n/a |
| <a name="module_loki_coordinator"></a> [loki\_coordinator](#module\_loki\_coordinator) | git::https://github.com/canonical/loki-operators//coordinator/terraform | n/a |
| <a name="module_loki_worker"></a> [loki\_worker](#module\_loki\_worker) | git::https://github.com/canonical/loki-operators//worker/terraform | n/a |
| <a name="module_loki_worker_backend"></a> [loki\_worker\_backend](#module\_loki\_worker\_backend) | git::https://github.com/canonical/loki-operators//worker/terraform | n/a |
| <a name="module_loki_worker_read"></a> [loki\_worker\_read](#module\_loki\_worker\_read) | git::https://github.com/canonical/loki-operators//worker/terraform | n/a |
| <a name="module_loki_worker_write"></a> [loki\_worker\_write](#module\_loki\_worker\_write) | git::https://github.com/canonical/loki-operators//worker/terraform | n/a |
| <a name="module_mimir_coordinator"></a> [mimir\_coordinator](#module\_mimir\_coordinator) | git::https://github.com/canonical/mimir-operators//coordinator/terraform | n/a |
| <a name="module_mimir_worker"></a> [mimir\_worker](#module\_mimir\_worker) | git::https://github.com/canonical/mimir-operators//worker/terraform | n/a |
| <a name="module_mimir_worker_backend"></a> [mimir\_worker\_backend](#module\_mimir\_worker\_backend) | git::https://github.com/canonical/mimir-operators//worker/terraform | n/a |
| <a name="module_mimir_worker_read"></a> [mimir\_worker\_read](#module\_mimir\_worker\_read) | git::https://github.com/canonical/mimir-operators//worker/terraform | n/a |
| <a name="module_mimir_worker_write"></a> [mimir\_worker\_write](#module\_mimir\_worker\_write) | git::https://github.com/canonical/mimir-operators//worker/terraform | n/a |
| <a name="module_opentelemetry_collector"></a> [opentelemetry\_collector](#module\_opentelemetry\_collector) | git::https://github.com/canonical/opentelemetry-collector-k8s-operator//terraform | n/a |
| <a name="module_seaweedfs"></a> [seaweedfs](#module\_seaweedfs) | git::https://github.com/canonical/observability-stack//terraform/seaweedfs | n/a |
| <a name="module_ssc"></a> [ssc](#module\_ssc) | git::https://github.com/canonical/self-signed-certificates-operator//terraform | n/a |
| <a name="module_tempo_coordinator"></a> [tempo\_coordinator](#module\_tempo\_coordinator) | git::https://github.com/canonical/tempo-operators//coordinator/terraform | n/a |
| <a name="module_tempo_worker"></a> [tempo\_worker](#module\_tempo\_worker) | git::https://github.com/canonical/tempo-operators//worker/terraform | n/a |
| <a name="module_tempo_worker_compactor"></a> [tempo\_worker\_compactor](#module\_tempo\_worker\_compactor) | git::https://github.com/canonical/tempo-operators//worker/terraform | n/a |
| <a name="module_tempo_worker_distributor"></a> [tempo\_worker\_distributor](#module\_tempo\_worker\_distributor) | git::https://github.com/canonical/tempo-operators//worker/terraform | n/a |
| <a name="module_tempo_worker_ingester"></a> [tempo\_worker\_ingester](#module\_tempo\_worker\_ingester) | git::https://github.com/canonical/tempo-operators//worker/terraform | n/a |
| <a name="module_tempo_worker_metrics_generator"></a> [tempo\_worker\_metrics\_generator](#module\_tempo\_worker\_metrics\_generator) | git::https://github.com/canonical/tempo-operators//worker/terraform | n/a |
| <a name="module_tempo_worker_querier"></a> [tempo\_worker\_querier](#module\_tempo\_worker\_querier) | git::https://github.com/canonical/tempo-operators//worker/terraform | n/a |
| <a name="module_tempo_worker_query_frontend"></a> [tempo\_worker\_query\_frontend](#module\_tempo\_worker\_query\_frontend) | git::https://github.com/canonical/tempo-operators//worker/terraform | n/a |
| <a name="module_traefik"></a> [traefik](#module\_traefik) | git::https://github.com/canonical/traefik-k8s-operator//terraform | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alertmanager"></a> [alertmanager](#input\_alertmanager) | Application configuration for Alertmanager. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "alertmanager")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_base"></a> [base](#input\_base) | The operating system on which to deploy. E.g. ubuntu@24.04. Check Charmhub for per-charm base support. | `string` | `"ubuntu@24.04"` | no |
| <a name="input_catalogue"></a> [catalogue](#input\_catalogue) | Application configuration for Catalogue. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "catalogue")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_external_ca_cert_offer_url"></a> [external\_ca\_cert\_offer\_url](#input\_external\_ca\_cert\_offer\_url) | A Juju offer URL (e.g. admin/external-ca.send-ca-cert) of a CA providing the 'certificate\_transfer' integration for applications to trust ingress via Traefik. | `string` | `null` | no |
| <a name="input_external_certificates_offer_url"></a> [external\_certificates\_offer\_url](#input\_external\_certificates\_offer\_url) | A Juju offer URL of a CA providing the 'tls\_certificates' integration for Traefik to supply it with server certificates | `string` | `null` | no |
| <a name="input_grafana"></a> [grafana](#input\_grafana) | Application configuration for Grafana. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "grafana")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Per-component toggle for ingress integrations | <pre>object({<br/>    alertmanager            = optional(bool, true)<br/>    catalogue               = optional(bool, true)<br/>    grafana                 = optional(bool, true)<br/>    loki                    = optional(bool, true)<br/>    mimir                   = optional(bool, true)<br/>    opentelemetry_collector = optional(bool, true)<br/>    tempo                   = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_internal_tls"></a> [internal\_tls](#input\_internal\_tls) | Specify whether to use TLS or not for internal COS communication. By default, TLS is enabled using self-signed-certificates | `bool` | `true` | no |
| <a name="input_loki_bucket"></a> [loki\_bucket](#input\_loki\_bucket) | Loki S3 bucket name | `string` | `"loki"` | no |
| <a name="input_loki_coordinator"></a> [loki\_coordinator](#input\_loki\_coordinator) | Application configuration for the Loki coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "loki")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_loki_worker"></a> [loki\_worker](#input\_loki\_worker) | Application configuration for the Loki worker(s). For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name    = optional(string, "loki-worker")<br/>    constraints = optional(string, "arch=amd64")<br/>    revision    = optional(number, null)<br/>    # Monolithic mode (role-all)<br/>    config             = optional(map(string), {})<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>    # Distributed mode<br/>    backend_config             = optional(map(string), {})<br/>    read_config                = optional(map(string), {})<br/>    write_config               = optional(map(string), {})<br/>    backend_storage_directives = optional(map(string), {})<br/>    read_storage_directives    = optional(map(string), {})<br/>    write_storage_directives   = optional(map(string), {})<br/>    backend_units              = optional(number, 1)<br/>    read_units                 = optional(number, 1)<br/>    write_units                = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_mimir_bucket"></a> [mimir\_bucket](#input\_mimir\_bucket) | Mimir S3 bucket name | `string` | `"mimir"` | no |
| <a name="input_mimir_coordinator"></a> [mimir\_coordinator](#input\_mimir\_coordinator) | Application configuration for the Mimir coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "mimir")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_mimir_worker"></a> [mimir\_worker](#input\_mimir\_worker) | Application configuration for the Mimir worker(s). For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name    = optional(string, "mimir-worker")<br/>    constraints = optional(string, "arch=amd64")<br/>    revision    = optional(number, null)<br/>    # Monolithic mode (role-all)<br/>    config             = optional(map(string), {})<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>    # Distributed mode<br/>    backend_config             = optional(map(string), {})<br/>    read_config                = optional(map(string), {})<br/>    write_config               = optional(map(string), {})<br/>    backend_storage_directives = optional(map(string), {})<br/>    read_storage_directives    = optional(map(string), {})<br/>    write_storage_directives   = optional(map(string), {})<br/>    backend_units              = optional(number, 1)<br/>    read_units                 = optional(number, 1)<br/>    write_units                = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_model_uuid"></a> [model\_uuid](#input\_model\_uuid) | Reference to an existing model resource or data source for the model to deploy to | `string` | n/a | yes |
| <a name="input_opentelemetry_collector"></a> [opentelemetry\_collector](#input\_opentelemetry\_collector) | Application configuration for OpenTelemetry Collector. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "otelcol")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_risk"></a> [risk](#input\_risk) | Risk level that the applications are (unless overwritten by individual channels) deployed from | `string` | `"edge"` | no |
| <a name="input_s3_access_key"></a> [s3\_access\_key](#input\_s3\_access\_key) | S3 access-key credential. Required when storage\_backend is 's3'. | `string` | `null` | no |
| <a name="input_s3_endpoint"></a> [s3\_endpoint](#input\_s3\_endpoint) | S3 endpoint URL. Required when storage\_backend is 's3'. | `string` | `null` | no |
| <a name="input_s3_integrator"></a> [s3\_integrator](#input\_s3\_integrator) | Application configuration shared by all S3-integrators (one deployed per coordinated worker). For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_s3_secret_key"></a> [s3\_secret\_key](#input\_s3\_secret\_key) | S3 secret-key credential. Required when storage\_backend is 's3'. | `string` | `null` | no |
| <a name="input_seaweedfs"></a> [seaweedfs](#input\_seaweedfs) | Application configuration for SeaweedFS. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "seaweedfs")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_ssc"></a> [ssc](#input\_ssc) | Application configuration for Self-signed-certificates. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "ca")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_storage_backend"></a> [storage\_backend](#input\_storage\_backend) | Storage backend: 'seaweedfs' (built-in S3-compatible storage) or 's3' (external S3/Ceph via s3-integrator). | `string` | `"seaweedfs"` | no |
| <a name="input_tempo_bucket"></a> [tempo\_bucket](#input\_tempo\_bucket) | Tempo S3 bucket name | `string` | `"tempo"` | no |
| <a name="input_tempo_coordinator"></a> [tempo\_coordinator](#input\_tempo\_coordinator) | Application configuration for the Tempo coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "tempo")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_tempo_worker"></a> [tempo\_worker](#input\_tempo\_worker) | Application configuration for the Tempo worker(s). For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name    = optional(string, "tempo-worker")<br/>    constraints = optional(string, "arch=amd64")<br/>    revision    = optional(number, null)<br/>    # Monolithic mode (role-all)<br/>    config             = optional(map(string), {})<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>    # Distributed mode<br/>    querier_config                       = optional(map(string), {})<br/>    query_frontend_config                = optional(map(string), {})<br/>    ingester_config                      = optional(map(string), {})<br/>    distributor_config                   = optional(map(string), {})<br/>    compactor_config                     = optional(map(string), {})<br/>    metrics_generator_config             = optional(map(string), {})<br/>    querier_storage_directives           = optional(map(string), {})<br/>    query_frontend_storage_directives    = optional(map(string), {})<br/>    ingester_storage_directives          = optional(map(string), {})<br/>    distributor_storage_directives       = optional(map(string), {})<br/>    compactor_storage_directives         = optional(map(string), {})<br/>    metrics_generator_storage_directives = optional(map(string), {})<br/>    querier_units                        = optional(number, 1)<br/>    query_frontend_units                 = optional(number, 1)<br/>    ingester_units                       = optional(number, 1)<br/>    distributor_units                    = optional(number, 1)<br/>    compactor_units                      = optional(number, 1)<br/>    metrics_generator_units              = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_topology"></a> [topology](#input\_topology) | Deployment topology: 'monolithic' (single role-all worker per component) or 'distributed' (separate workers per role). | `string` | `"monolithic"` | no |
| <a name="input_traefik"></a> [traefik](#input\_traefik) | Application configuration for Traefik. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application | <pre>object({<br/>    app_name           = optional(string, "traefik")<br/>    config             = optional(map(string), {})<br/>    constraints        = optional(string, "arch=amd64")<br/>    revision           = optional(number, null)<br/>    storage_directives = optional(map(string), {})<br/>    units              = optional(number, 1)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_components"></a> [components](#output\_components) | All Terraform charm modules which make up this product module |
| <a name="output_offers"></a> [offers](#output\_offers) | All Juju offers which are exposed by this product module |
<!-- END_TF_DOCS -->

## Usage

### Basic usage

To deploy the COS Dev solution in a model named `cos-dev`, create this root module:

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

resource "juju_model" "cos-dev" {
  name = "cos-dev"
}

module "cos-dev" {
  source     = "git::https://github.com/canonical/observability-stack//terraform/cos-dev"
  model_uuid = juju_model.cos-dev.uuid
}
```

Then, use terraform to deploy the module:

```shell
terraform init
terraform apply
```

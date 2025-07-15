# Terraform module for COS solution

This is a Terraform module facilitating the deployment of COS solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs). This Terraform module deploys COS with Mimir, Tempo and Loki in their microservices modes, and other charms in monolithic mode.

> [!NOTE]
> `s3-integrator` itself doesn't act as an S3 object storage system. For the HA solution to be functional, `s3-integrator` needs to point to an S3-like storage. See [this guide](https://discourse.charmhub.io/t/cos-lite-docs-set-up-minio/15211) to learn how to connect to an S3-like storage for traces.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | >= 0.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | >= 0.20.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alertmanager"></a> [alertmanager](#module\_alertmanager) | git::https://github.com/canonical/alertmanager-k8s-operator//terraform | n/a |
| <a name="module_catalogue"></a> [catalogue](#module\_catalogue) | git::https://github.com/canonical/catalogue-k8s-operator//terraform | n/a |
| <a name="module_grafana"></a> [grafana](#module\_grafana) | git::https://github.com/canonical/grafana-k8s-operator//terraform | n/a |
| <a name="module_grafana_agent"></a> [grafana\_agent](#module\_grafana\_agent) | git::https://github.com/canonical/grafana-agent-k8s-operator//terraform | n/a |
| <a name="module_loki"></a> [loki](#module\_loki) | git::https://github.com/canonical/observability-stack//terraform/loki | n/a |
| <a name="module_mimir"></a> [mimir](#module\_mimir) | git::https://github.com/canonical/observability-stack//terraform/mimir | n/a |
| <a name="module_ssc"></a> [ssc](#module\_ssc) | git::https://github.com/canonical/self-signed-certificates-operator//terraform | n/a |
| <a name="module_tempo"></a> [tempo](#module\_tempo) | git::https://github.com/canonical/observability-stack//terraform/tempo | n/a |
| <a name="module_traefik"></a> [traefik](#module\_traefik) | git::https://github.com/canonical/traefik-k8s-operator//terraform | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alertmanager_config"></a> [alertmanager\_config](#input\_alertmanager\_config) | Map of the Alertmanager configuration options | `map(string)` | `{}` | no |
| <a name="input_alertmanager_constraints"></a> [alertmanager\_constraints](#input\_alertmanager\_constraints) | String listing constraints for the Alertmanager application | `string` | `"arch=amd64"` | no |
| <a name="input_alertmanager_revision"></a> [alertmanager\_revision](#input\_alertmanager\_revision) | Revision number of the Alertmanager application | `number` | `null` | no |
| <a name="input_alertmanager_storage_directives"></a> [alertmanager\_storage\_directives](#input\_alertmanager\_storage\_directives) | Map of storage used by the Alertmanager application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_alertmanager_units"></a> [alertmanager\_units](#input\_alertmanager\_units) | Unit count/scale of the Alertmanager application | `number` | `1` | no |
| <a name="input_anti_affinity"></a> [anti\_affinity](#input\_anti\_affinity) | Enable anti-affinity constraints across all HA modules (Mimir, Loki, Tempo) | `bool` | `true` | no |
| <a name="input_catalogue_config"></a> [catalogue\_config](#input\_catalogue\_config) | Map of the Catalogue configuration options | `map(string)` | `{}` | no |
| <a name="input_catalogue_constraints"></a> [catalogue\_constraints](#input\_catalogue\_constraints) | String listing constraints for the Catalogue application | `string` | `"arch=amd64"` | no |
| <a name="input_catalogue_revision"></a> [catalogue\_revision](#input\_catalogue\_revision) | Revision number of the Catalogue application | `number` | `null` | no |
| <a name="input_catalogue_storage_directives"></a> [catalogue\_storage\_directives](#input\_catalogue\_storage\_directives) | Map of storage used by the Catalogue application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_catalogue_units"></a> [catalogue\_units](#input\_catalogue\_units) | Unit count/scale of the Catalogue application | `number` | `1` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | Channel that the applications are (unless overwritten by external\_channels) deployed from | `string` | n/a | yes |
| <a name="input_cloud"></a> [cloud](#input\_cloud) | Kubernetes cloud or environment where this COS module will be deployed (e.g self-managed, aws) | `string` | `"self-managed"` | no |
| <a name="input_external_certificates_offer_url"></a> [external\_certificates\_offer\_url](#input\_external\_certificates\_offer\_url) | A Juju offer URL of a CA providing the 'tls\_certificates' integration for Traefik to supply it with server certificates | `string` | `null` | no |
| <a name="input_grafana_agent_config"></a> [grafana\_agent\_config](#input\_grafana\_agent\_config) | Map of the Grafana agent configuration options | `map(string)` | `{}` | no |
| <a name="input_grafana_agent_constraints"></a> [grafana\_agent\_constraints](#input\_grafana\_agent\_constraints) | String listing constraints for the Grafana agent application | `string` | `"arch=amd64"` | no |
| <a name="input_grafana_agent_revision"></a> [grafana\_agent\_revision](#input\_grafana\_agent\_revision) | Revision number of the Grafana agent application | `number` | `null` | no |
| <a name="input_grafana_agent_storage_directives"></a> [grafana\_agent\_storage\_directives](#input\_grafana\_agent\_storage\_directives) | Map of storage used by the Grafana agent application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_grafana_agent_units"></a> [grafana\_agent\_units](#input\_grafana\_agent\_units) | Unit count/scale of the Grafana agent application | `number` | `1` | no |
| <a name="input_grafana_config"></a> [grafana\_config](#input\_grafana\_config) | Map of the Grafana configuration options | `map(string)` | `{}` | no |
| <a name="input_grafana_constraints"></a> [grafana\_constraints](#input\_grafana\_constraints) | String listing constraints for the Grafana application | `string` | `"arch=amd64"` | no |
| <a name="input_grafana_revision"></a> [grafana\_revision](#input\_grafana\_revision) | Revision number of the Grafana application | `number` | `null` | no |
| <a name="input_grafana_storage_directives"></a> [grafana\_storage\_directives](#input\_grafana\_storage\_directives) | Map of storage used by the Grafana application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_grafana_units"></a> [grafana\_units](#input\_grafana\_units) | Unit count/scale of the Grafana application | `number` | `1` | no |
| <a name="input_internal_tls"></a> [internal\_tls](#input\_internal\_tls) | Specify whether to use TLS or not for internal COS communication. By default, TLS is enabled using self-signed-certificates | `bool` | `true` | no |
| <a name="input_loki_backend_config"></a> [loki\_backend\_config](#input\_loki\_backend\_config) | Map of the Loki backend worker configuration options | `map(string)` | `{}` | no |
| <a name="input_loki_backend_units"></a> [loki\_backend\_units](#input\_loki\_backend\_units) | Count/scale of Loki worker units with backend role | `number` | `3` | no |
| <a name="input_loki_bucket"></a> [loki\_bucket](#input\_loki\_bucket) | Loki bucket name | `string` | n/a | yes |
| <a name="input_loki_coordinator_config"></a> [loki\_coordinator\_config](#input\_loki\_coordinator\_config) | Map of the Loki coordinator configuration options | `map(string)` | `{}` | no |
| <a name="input_loki_coordinator_constraints"></a> [loki\_coordinator\_constraints](#input\_loki\_coordinator\_constraints) | String listing constraints for the Loki coordinator application | `string` | `"arch=amd64"` | no |
| <a name="input_loki_coordinator_revision"></a> [loki\_coordinator\_revision](#input\_loki\_coordinator\_revision) | Revision number of the Loki coordinator application | `number` | `null` | no |
| <a name="input_loki_coordinator_storage_directives"></a> [loki\_coordinator\_storage\_directives](#input\_loki\_coordinator\_storage\_directives) | Map of storage used by the Loki coordinator application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_loki_coordinator_units"></a> [loki\_coordinator\_units](#input\_loki\_coordinator\_units) | Count/scale of the Loki coordinator units | `number` | `3` | no |
| <a name="input_loki_read_config"></a> [loki\_read\_config](#input\_loki\_read\_config) | Map of the Loki read worker configuration options | `map(string)` | `{}` | no |
| <a name="input_loki_read_units"></a> [loki\_read\_units](#input\_loki\_read\_units) | Count/scale of Loki worker units with read role | `number` | `3` | no |
| <a name="input_loki_worker_constraints"></a> [loki\_worker\_constraints](#input\_loki\_worker\_constraints) | String listing constraints for the Loki worker application | `string` | `"arch=amd64"` | no |
| <a name="input_loki_worker_revision"></a> [loki\_worker\_revision](#input\_loki\_worker\_revision) | Revision number of the Loki worker application | `number` | `null` | no |
| <a name="input_loki_worker_storage_directives"></a> [loki\_worker\_storage\_directives](#input\_loki\_worker\_storage\_directives) | Map of storage used by the Loki worker application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_loki_write_config"></a> [loki\_write\_config](#input\_loki\_write\_config) | Map of the Loki write worker configuration options | `map(string)` | `{}` | no |
| <a name="input_loki_write_units"></a> [loki\_write\_units](#input\_loki\_write\_units) | Count/scale of Loki worker units with write roles | `number` | `3` | no |
| <a name="input_mimir_backend_config"></a> [mimir\_backend\_config](#input\_mimir\_backend\_config) | Map of the Mimir backend worker configuration options | `map(string)` | `{}` | no |
| <a name="input_mimir_backend_units"></a> [mimir\_backend\_units](#input\_mimir\_backend\_units) | Count/scale of Mimir worker units with backend role | `number` | `3` | no |
| <a name="input_mimir_bucket"></a> [mimir\_bucket](#input\_mimir\_bucket) | Mimir bucket name | `string` | n/a | yes |
| <a name="input_mimir_coordinator_config"></a> [mimir\_coordinator\_config](#input\_mimir\_coordinator\_config) | Map of the Mimir coordinator configuration options | `map(string)` | `{}` | no |
| <a name="input_mimir_coordinator_constraints"></a> [mimir\_coordinator\_constraints](#input\_mimir\_coordinator\_constraints) | String listing constraints for the Mimir coordinator application | `string` | `"arch=amd64"` | no |
| <a name="input_mimir_coordinator_revision"></a> [mimir\_coordinator\_revision](#input\_mimir\_coordinator\_revision) | Revision number of the Mimir coordinator application | `number` | `null` | no |
| <a name="input_mimir_coordinator_storage_directives"></a> [mimir\_coordinator\_storage\_directives](#input\_mimir\_coordinator\_storage\_directives) | Map of storage used by the Mimir coordinator application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_mimir_coordinator_units"></a> [mimir\_coordinator\_units](#input\_mimir\_coordinator\_units) | Count/scale of Mimir coordinator units | `number` | `3` | no |
| <a name="input_mimir_read_config"></a> [mimir\_read\_config](#input\_mimir\_read\_config) | Map of the Mimir read worker configuration options | `map(string)` | `{}` | no |
| <a name="input_mimir_read_units"></a> [mimir\_read\_units](#input\_mimir\_read\_units) | Count/scale of Mimir worker units with read role | `number` | `3` | no |
| <a name="input_mimir_worker_constraints"></a> [mimir\_worker\_constraints](#input\_mimir\_worker\_constraints) | String listing constraints for the Mimir worker application | `string` | `"arch=amd64"` | no |
| <a name="input_mimir_worker_revision"></a> [mimir\_worker\_revision](#input\_mimir\_worker\_revision) | Revision number of the Mimir worker application | `number` | `null` | no |
| <a name="input_mimir_worker_storage_directives"></a> [mimir\_worker\_storage\_directives](#input\_mimir\_worker\_storage\_directives) | Map of storage used by the Mimir worker application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_mimir_write_config"></a> [mimir\_write\_config](#input\_mimir\_write\_config) | Map of the Mimir write worker configuration options | `map(string)` | `{}` | no |
| <a name="input_mimir_write_units"></a> [mimir\_write\_units](#input\_mimir\_write\_units) | Count/scale of Mimir worker units with write role | `number` | `3` | no |
| <a name="input_model"></a> [model](#input\_model) | Reference to an existing model resource or data source for the model to deploy to | `string` | n/a | yes |
| <a name="input_s3_access_key"></a> [s3\_access\_key](#input\_s3\_access\_key) | S3 access-key credential | `string` | n/a | yes |
| <a name="input_s3_endpoint"></a> [s3\_endpoint](#input\_s3\_endpoint) | S3 endpoint | `string` | n/a | yes |
| <a name="input_s3_integrator_channel"></a> [s3\_integrator\_channel](#input\_s3\_integrator\_channel) | Channel that the s3-integrator application is deployed from | `string` | `"2/edge"` | no |
| <a name="input_s3_integrator_config"></a> [s3\_integrator\_config](#input\_s3\_integrator\_config) | Map of the s3-integrator configuration options | `map(string)` | `{}` | no |
| <a name="input_s3_integrator_constraints"></a> [s3\_integrator\_constraints](#input\_s3\_integrator\_constraints) | String listing constraints for the s3-integrator application | `string` | `"arch=amd64"` | no |
| <a name="input_s3_integrator_revision"></a> [s3\_integrator\_revision](#input\_s3\_integrator\_revision) | Revision number of the s3-integrator application | `number` | `157` | no |
| <a name="input_s3_integrator_storage_directives"></a> [s3\_integrator\_storage\_directives](#input\_s3\_integrator\_storage\_directives) | Map of storage used by the s3-integrator application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_s3_integrator_units"></a> [s3\_integrator\_units](#input\_s3\_integrator\_units) | Unit count/scale of the s3-integrator application | `number` | `1` | no |
| <a name="input_s3_secret_key"></a> [s3\_secret\_key](#input\_s3\_secret\_key) | S3 secret-key credential | `string` | n/a | yes |
| <a name="input_ssc_channel"></a> [ssc\_channel](#input\_ssc\_channel) | Channel that the self-signed certificates application is deployed from | `string` | `"1/stable"` | no |
| <a name="input_ssc_config"></a> [ssc\_config](#input\_ssc\_config) | Map of the self-signed certificates configuration options | `map(string)` | `{}` | no |
| <a name="input_ssc_constraints"></a> [ssc\_constraints](#input\_ssc\_constraints) | String listing constraints for the self-signed certificates application | `string` | `"arch=amd64"` | no |
| <a name="input_ssc_revision"></a> [ssc\_revision](#input\_ssc\_revision) | Revision number of the self-signed certificates application | `number` | `null` | no |
| <a name="input_ssc_storage_directives"></a> [ssc\_storage\_directives](#input\_ssc\_storage\_directives) | Map of storage used by the self-signed certificates application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_ssc_units"></a> [ssc\_units](#input\_ssc\_units) | Unit count/scale of the self-signed certificates application | `number` | `1` | no |
| <a name="input_tempo_bucket"></a> [tempo\_bucket](#input\_tempo\_bucket) | Tempo bucket name | `string` | n/a | yes |
| <a name="input_tempo_compactor_config"></a> [tempo\_compactor\_config](#input\_tempo\_compactor\_config) | Map of the Tempo compactor worker configuration options | `map(string)` | `{}` | no |
| <a name="input_tempo_compactor_units"></a> [tempo\_compactor\_units](#input\_tempo\_compactor\_units) | Count/scale of Tempo worker units with compactor role | `number` | `3` | no |
| <a name="input_tempo_coordinator_config"></a> [tempo\_coordinator\_config](#input\_tempo\_coordinator\_config) | Map of the Tempo coordinator configuration options | `map(string)` | `{}` | no |
| <a name="input_tempo_coordinator_constraints"></a> [tempo\_coordinator\_constraints](#input\_tempo\_coordinator\_constraints) | String listing constraints for the Tempo coordinator application | `string` | `"arch=amd64"` | no |
| <a name="input_tempo_coordinator_revision"></a> [tempo\_coordinator\_revision](#input\_tempo\_coordinator\_revision) | Revision number of the Tempo coordinator application | `number` | `null` | no |
| <a name="input_tempo_coordinator_storage_directives"></a> [tempo\_coordinator\_storage\_directives](#input\_tempo\_coordinator\_storage\_directives) | Map of storage used by the Tempo coordinator application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_tempo_coordinator_units"></a> [tempo\_coordinator\_units](#input\_tempo\_coordinator\_units) | Count/scale of Tempo coordinator units | `number` | `3` | no |
| <a name="input_tempo_distributor_config"></a> [tempo\_distributor\_config](#input\_tempo\_distributor\_config) | Map of the Tempo distributor worker configuration options | `map(string)` | `{}` | no |
| <a name="input_tempo_distributor_units"></a> [tempo\_distributor\_units](#input\_tempo\_distributor\_units) | Count/scale of Tempo worker units with distributor role | `number` | `3` | no |
| <a name="input_tempo_ingester_config"></a> [tempo\_ingester\_config](#input\_tempo\_ingester\_config) | Map of the Tempo ingester worker configuration options | `map(string)` | `{}` | no |
| <a name="input_tempo_ingester_units"></a> [tempo\_ingester\_units](#input\_tempo\_ingester\_units) | Count/scale of Tempo worker units with ingester role | `number` | `3` | no |
| <a name="input_tempo_metrics_generator_config"></a> [tempo\_metrics\_generator\_config](#input\_tempo\_metrics\_generator\_config) | Map of the Tempo metrics-generator worker configuration options | `map(string)` | `{}` | no |
| <a name="input_tempo_metrics_generator_units"></a> [tempo\_metrics\_generator\_units](#input\_tempo\_metrics\_generator\_units) | Count/scale of Tempo worker units with metrics-generator role | `number` | `3` | no |
| <a name="input_tempo_querier_config"></a> [tempo\_querier\_config](#input\_tempo\_querier\_config) | Map of the Tempo querier worker configuration options | `map(string)` | `{}` | no |
| <a name="input_tempo_querier_units"></a> [tempo\_querier\_units](#input\_tempo\_querier\_units) | Count/scale of Tempo worker units with querier role | `number` | `3` | no |
| <a name="input_tempo_query_frontend_config"></a> [tempo\_query\_frontend\_config](#input\_tempo\_query\_frontend\_config) | Map of the Tempo query-frontend worker configuration options | `map(string)` | `{}` | no |
| <a name="input_tempo_query_frontend_units"></a> [tempo\_query\_frontend\_units](#input\_tempo\_query\_frontend\_units) | Count/scale of Tempo worker units with query-frontend role | `number` | `3` | no |
| <a name="input_tempo_worker_constraints"></a> [tempo\_worker\_constraints](#input\_tempo\_worker\_constraints) | String listing constraints for the Tempo worker application | `string` | `"arch=amd64"` | no |
| <a name="input_tempo_worker_revision"></a> [tempo\_worker\_revision](#input\_tempo\_worker\_revision) | Revision number of the Tempo worker application | `number` | `null` | no |
| <a name="input_tempo_worker_storage_directives"></a> [tempo\_worker\_storage\_directives](#input\_tempo\_worker\_storage\_directives) | Map of storage used by the Tempo worker application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
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

### High Availability

By default, this Terraform module will deploy each worker with `3` unit. If you want to scale each Loki, Mimir or Tempo worker unit please check the variables available for that purpose in `variables.tf`.

### Minimal sample deployment.

In order to deploy COS with just one unit per worker charm create a `main.tf` file with the following content:

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# COS module that deploy the whole Canonical Observability Stack
module "cos" {
    source                        = "git::https://github.com/canonical/observability-stack//terraform/cos"
    model                         = "cos"
    channel                       = "2/edge"
    s3_integrator_channel         = "2/edge"
    ssc_channel                   = "1/edge"
    traefik_channel               = "latest/edge"
    cloud                         = "self-managed"
    use_tls                       = true
    s3_endpoint                   = "http://S3_HOST_IP:8080"
    s3_secret_key                 = "secret-key"
    s3_access_key                 = "access-key"
    loki_bucket                   = "loki"
    mimir_bucket                  = "mimir"
    tempo_bucket                  = "tempo"
    loki_coordinator_units        = 3
    loki_backend_units            = 3
    loki_read_units               = 3
    loki_write_units              = 3
    mimir_coordinator_units       = 3
    mimir_backend_units           = 3
    mimir_read_units              = 3
    mimir_write_units             = 3
    tempo_coordinator_units       = 3
    tempo_compactor_units         = 3
    tempo_distributor_units       = 3
    tempo_ingester_units          = 3
    tempo_metrics_generator_units = 3
    tempo_querier_units           = 3
    tempo_query_frontend_units    = 3
    alertmanager_revision         = null
    catalogue_revision            = null
    grafana_revision              = null
    grafana_agent_revision        = null
    loki_coordinator_revision     = null
    loki_worker_revision          = null
    mimir_coordinator_revision    = null
    mimir_worker_revision         = null
    ssc_revision                  = null
    s3_integrator_revision        = 157 # FIXME: https://github.com/canonical/observability/issues/342
    tempo_coordinator_revision    = null
    tempo_worker_revision         = null
    traefik_revision              = null
}
```

Then, use terraform to deploy the module:

```shell
terraform init
terraform apply
```

Some minutes after running these two commands, we have a distributed COS deployment!

```shell
$ juju status --relations
Model  Controller  Cloud/Region        Version  SLA          Timestamp
cos    microk8s    microk8s/localhost  3.6.2    unsupported  20:16:42-03:00

App                       Version  Status  Scale  Charm                     Channel      Rev  Address         Exposed  Message
alertmanager              0.27.0   active      1  alertmanager-k8s          latest/edge  156  10.152.183.57   no
catalogue                          active      1  catalogue-k8s             latest/edge   81  10.152.183.88   no
grafana                   9.5.3    active      1  grafana-k8s               latest/edge  141  10.152.183.138  no
grafana-agent             0.40.4   active      1  grafana-agent-k8s         latest/edge  112  10.152.183.37   no       grafana-dashboards-provider: off
loki                               active      3  loki-coordinator-k8s      latest/edge   20  10.152.183.201  no
loki-backend              3.0.0    active      3  loki-worker-k8s           latest/edge   34  10.152.183.112  no       backend ready.
loki-read                 3.0.0    active      3  loki-worker-k8s           latest/edge   34  10.152.183.87   no       read ready.
loki-s3-integrator                 active      1  s3-integrator             latest/edge  139  10.152.183.20   no
loki-write                3.0.0    active      3  loki-worker-k8s           latest/edge   34  10.152.183.167  no       write ready.
mimir                              active      3  mimir-coordinator-k8s     latest/edge   38  10.152.183.207  no
mimir-backend             2.13.0   active      3  mimir-worker-k8s          latest/edge   45  10.152.183.45   no       backend ready.
mimir-read                2.13.0   active      3  mimir-worker-k8s          latest/edge   45  10.152.183.160  no       read ready.
mimir-s3-integrator                active      1  s3-integrator             latest/edge  139  10.152.183.85   no
mimir-write               2.13.0   active      3  mimir-worker-k8s          latest/edge   45  10.152.183.125  no       write ready.
self-signed-certificates           active      1  self-signed-certificates  1/edge       268  10.152.183.34   no
tempo                              active      3  tempo-coordinator-k8s     latest/edge   70  10.152.183.72   no
tempo-compactor           2.7.1    active      3  tempo-worker-k8s          latest/edge   52  10.152.183.99   no       compactor ready.
tempo-distributor         2.7.1    active      3  tempo-worker-k8s          latest/edge   52  10.152.183.162  no       distributor ready.
tempo-ingester            2.7.1    active      3  tempo-worker-k8s          latest/edge   52  10.152.183.195  no       ingester ready.
tempo-metrics-generator   2.7.1    active      3  tempo-worker-k8s          latest/edge   52  10.152.183.122  no       metrics-generator ready.
tempo-querier             2.7.1    active      3  tempo-worker-k8s          latest/edge   52  10.152.183.136  no       querier ready.
tempo-query-frontend      2.7.1    active      3  tempo-worker-k8s          latest/edge   52  10.152.183.105  no       query-frontend ready.
tempo-s3-integrator                active      1  s3-integrator             latest/edge  139  10.152.183.121  no
traefik                   2.11.0   active      1  traefik-k8s               latest/edge  234  10.152.183.110  no       Serving at 192.168.1.244

Unit                         Workload  Agent  Address       Ports  Message
alertmanager/0*              active    idle   10.1.167.134
catalogue/0*                 active    idle   10.1.167.150
grafana-agent/0*             active    idle   10.1.167.149         grafana-dashboards-provider: off
grafana/0*                   active    idle   10.1.167.173
loki-backend/0*              active    idle   10.1.167.148         backend ready.
loki-backend/1               active    idle   10.1.167.171         backend ready.
loki-backend/2               active    idle   10.1.167.188         backend ready.
loki-read/0                  active    idle   10.1.167.153         read ready.
loki-read/1                  active    idle   10.1.167.180         read ready.
loki-read/2*                 active    idle   10.1.167.183         read ready.
loki-s3-integrator/0*        active    idle   10.1.167.169
loki-write/0*                active    idle   10.1.167.144         write ready.
loki-write/1                 active    idle   10.1.167.142         write ready.
loki-write/2                 active    idle   10.1.167.187         write ready.
loki/0*                      active    idle   10.1.167.174
mimir-backend/0*             active    idle   10.1.167.139         backend ready.
mimir-backend/1              active    idle   10.1.167.128         backend ready.
mimir-backend/2              active    idle   10.1.167.177         backend ready.
mimir-read/0*                active    idle   10.1.167.151         read ready.
mimir-read/1                 active    idle   10.1.167.163         read ready.
mimir-read/2                 active    idle   10.1.167.132         read ready.
mimir-s3-integrator/0*       active    idle   10.1.167.137
mimir-write/0*               active    idle   10.1.167.152         write ready.
mimir-write/1                active    idle   10.1.167.167         write ready.
mimir-write/2                active    idle   10.1.167.143         write ready.
mimir/0*                     active    idle   10.1.167.135
self-signed-certificates/0*  active    idle   10.1.167.166
tempo-compactor/0            active    idle   10.1.167.181         compactor ready.
tempo-compactor/1*           active    idle   10.1.167.168         compactor ready.
tempo-compactor/2            active    idle   10.1.167.129         compactor ready.
tempo-distributor/0*         active    idle   10.1.167.157         distributor ready.
tempo-distributor/1          active    idle   10.1.167.131         distributor ready.
tempo-distributor/2          active    idle   10.1.167.186         distributor ready.
tempo-ingester/0*            active    idle   10.1.167.191         ingester ready.
tempo-ingester/1             active    idle   10.1.167.133         ingester ready.
tempo-ingester/2             active    idle   10.1.167.179         ingester ready.
tempo-metrics-generator/0*   active    idle   10.1.167.147         metrics-generator ready.
tempo-metrics-generator/1    active    idle   10.1.167.159         metrics-generator ready.
tempo-metrics-generator/2    active    idle   10.1.167.146         metrics-generator ready.
tempo-querier/0              active    idle   10.1.167.170         querier ready.
tempo-querier/1              active    idle   10.1.167.140         querier ready.
tempo-querier/2*             active    idle   10.1.167.165         querier ready.
tempo-query-frontend/0*      active    idle   10.1.167.162         query-frontend ready.
tempo-query-frontend/1       active    idle   10.1.167.190         query-frontend ready.
tempo-query-frontend/2       active    idle   10.1.167.184         query-frontend ready.
tempo-s3-integrator/0*       active    idle   10.1.167.172
tempo/0*                     active    idle   10.1.167.189
traefik/0*                   active    idle   10.1.167.182         Serving at 192.168.1.244

Integration provider                     Requirer                                 Interface                Type     Message
alertmanager:alerting                    loki:alertmanager                        alertmanager_dispatch    regular
alertmanager:alerting                    mimir:alertmanager                       alertmanager_dispatch    regular
alertmanager:grafana-dashboard           grafana:grafana-dashboard                grafana_dashboard        regular
alertmanager:grafana-source              grafana:grafana-source                   grafana_datasource       regular
alertmanager:replicas                    alertmanager:replicas                    alertmanager_replica     peer
alertmanager:self-metrics-endpoint       grafana-agent:metrics-endpoint           prometheus_scrape        regular
catalogue:catalogue                      alertmanager:catalogue                   catalogue                regular
catalogue:catalogue                      grafana:catalogue                        catalogue                regular
catalogue:catalogue                      mimir:catalogue                          catalogue                regular
catalogue:catalogue                      tempo:catalogue                          catalogue                regular
catalogue:replicas                       catalogue:replicas                       catalogue_replica        peer
grafana-agent:logging-provider           loki:logging-consumer                    loki_push_api            regular
grafana-agent:logging-provider           tempo:logging                            loki_push_api            regular
grafana-agent:peers                      grafana-agent:peers                      grafana_agent_replica    peer
grafana-agent:tracing-provider           grafana:charm-tracing                    tracing                  regular
grafana-agent:tracing-provider           loki:charm-tracing                       tracing                  regular
grafana-agent:tracing-provider           mimir:charm-tracing                      tracing                  regular
grafana:grafana                          grafana:grafana                          grafana_peers            peer
grafana:replicas                         grafana:replicas                         grafana_replicas         peer
loki-s3-integrator:s3-credentials        loki:s3                                  s3                       regular
loki-s3-integrator:s3-integrator-peers   loki-s3-integrator:s3-integrator-peers   s3-integrator-peers      peer
loki:grafana-dashboards-provider         grafana:grafana-dashboard                grafana_dashboard        regular
loki:grafana-source                      grafana:grafana-source                   grafana_datasource       regular
loki:logging                             grafana-agent:logging-consumer           loki_push_api            regular
loki:loki-cluster                        loki-backend:loki-cluster                loki_cluster             regular
loki:loki-cluster                        loki-read:loki-cluster                   loki_cluster             regular
loki:loki-cluster                        loki-write:loki-cluster                  loki_cluster             regular
loki:self-metrics-endpoint               grafana-agent:metrics-endpoint           prometheus_scrape        regular
mimir-s3-integrator:s3-credentials       mimir:s3                                 s3                       regular
mimir-s3-integrator:s3-integrator-peers  mimir-s3-integrator:s3-integrator-peers  s3-integrator-peers      peer
mimir:grafana-dashboards-provider        grafana:grafana-dashboard                grafana_dashboard        regular
mimir:grafana-source                     grafana:grafana-source                   grafana_datasource       regular
mimir:mimir-cluster                      mimir-backend:mimir-cluster              mimir_cluster            regular
mimir:mimir-cluster                      mimir-read:mimir-cluster                 mimir_cluster            regular
mimir:mimir-cluster                      mimir-write:mimir-cluster                mimir_cluster            regular
mimir:receive-remote-write               grafana-agent:send-remote-write          prometheus_remote_write  regular
mimir:receive-remote-write               tempo:send-remote-write                  prometheus_remote_write  regular
mimir:self-metrics-endpoint              grafana-agent:metrics-endpoint           prometheus_scrape        regular
tempo-s3-integrator:s3-credentials       tempo:s3                                 s3                       regular
tempo-s3-integrator:s3-integrator-peers  tempo-s3-integrator:s3-integrator-peers  s3-integrator-peers      peer
tempo:grafana-source                     grafana:grafana-source                   grafana_datasource       regular
tempo:metrics-endpoint                   grafana-agent:metrics-endpoint           prometheus_scrape        regular
tempo:peers                              tempo:peers                              tempo_peers              peer
tempo:tempo-cluster                      tempo-compactor:tempo-cluster            tempo_cluster            regular
tempo:tempo-cluster                      tempo-distributor:tempo-cluster          tempo_cluster            regular
tempo:tempo-cluster                      tempo-ingester:tempo-cluster             tempo_cluster            regular
tempo:tempo-cluster                      tempo-metrics-generator:tempo-cluster    tempo_cluster            regular
tempo:tempo-cluster                      tempo-querier:tempo-cluster              tempo_cluster            regular
tempo:tempo-cluster                      tempo-query-frontend:tempo-cluster       tempo_cluster            regular
tempo:tracing                            grafana-agent:tracing                    tracing                  regular
traefik:ingress                          alertmanager:ingress                     ingress                  regular
traefik:ingress                          catalogue:ingress                        ingress                  regular
traefik:ingress                          loki:ingress                             ingress                  regular
traefik:ingress                          mimir:ingress                            ingress                  regular
traefik:peers                            traefik:peers                            traefik_peers            peer
traefik:traefik-route                    grafana:ingress                          traefik_route            regular
traefik:traefik-route                    tempo:ingress                            traefik_route            regular
```

### Deploy COS on AWS EKS

> **Note:** This deployment assumes that the required AWS infrastructure is already provisioned and that a Juju controller has been bootstrapped.  
> Additionally, a Juju model must be ready in advance.
> 
> See [provision AWS infrastructure](../aws-infra/README.md)

In order to deploy COS on AWS, create a `main.tf` file with the following content.

```hcl
# COS module that deploy the whole Canonical Observability Stack
module "cos" {
  source                        = "git::https://github.com/canonical/observability-stack//terraform/cos"
  model                         = var.model
  channel                       = var.channel
  s3_endpoint                   = var.s3_endpoint
  s3_access_key                 = var.s3_access_key
  s3_secret_key                 = var.s3_secret_key
  loki_bucket                   = var.loki_bucket
  mimir_bucket                  = var.mimir_bucket
  tempo_bucket                  = var.tempo_bucket
  loki_backend_units            = var.loki_backend_units
  loki_read_units               = var.loki_read_units
  loki_write_units              = var.loki_write_units
  mimir_backend_units           = var.mimir_backend_units
  mimir_read_units              = var.mimir_read_units
  mimir_write_units             = var.mimir_write_units
  tempo_compactor_units         = var.tempo_compactor_units
  tempo_distributor_units       = var.tempo_distributor_units
  tempo_ingester_units          = var.tempo_ingester_units
  tempo_metrics_generator_units = var.tempo_metrics_generator_units
  tempo_querier_units           = var.tempo_querier_units
  tempo_query_frontend_units    = var.tempo_query_frontend_units
  cloud                         = var.cloud
  ssc_channel                   = var.ssc_channel
}

variable "channel" {
  description = "Charms channel"
  type        = string
  default     = "latest/edge"
}

variable "model" {
  description = "Model name"
  type        = string
}

variable "use_tls" {
  description = "Specify whether to use TLS or not for coordinator-worker communication. By default, TLS is enabled through self-signed-certificates"
  type        = bool
  default     = true
}

variable "s3_endpoint" {
  description = "S3 endpoint"
  type        = string
}

variable "s3_access_key" {
  description = "S3 access key"
  type        = string
  sensitive   = true
}

variable "s3_secret_key" {
  description = "S3 secret key"
  type        = string
  sensitive   = true
}

variable "loki_bucket" {
  description = "Loki bucket name"
  type        = string
  sensitive   = true
}

variable "mimir_bucket" {
  description = "Mimir bucket name"
  type        = string
  sensitive   = true
}

variable "tempo_bucket" {
  description = "Tempo bucket name"
  type        = string
  sensitive   = true
}

variable "loki_backend_units" {
  description = "Number of Loki worker units with backend role"
  type        = number
  default     = 3
}

variable "loki_read_units" {
  description = "Number of Loki worker units with read role"
  type        = number
  default     = 3
}

variable "loki_write_units" {
  description = "Number of Loki worker units with write roles"
  type        = number
  default     = 3
}

variable "mimir_backend_units" {
  description = "Number of Mimir worker units with backend role"
  type        = number
  default     = 3
}

variable "mimir_read_units" {
  description = "Number of Mimir worker units with read role"
  type        = number
  default     = 3
}

variable "mimir_write_units" {
  description = "Number of Mimir worker units with write role"
  type        = number
  default     = 3
}

variable "tempo_compactor_units" {
  description = "Number of Tempo worker units with compactor role"
  type        = number
  default     = 3
}

variable "tempo_distributor_units" {
  description = "Number of Tempo worker units with distributor role"
  type        = number
  default     = 3
}

variable "tempo_ingester_units" {
  description = "Number of Tempo worker units with ingester role"
  type        = number
  default     = 3
}

variable "tempo_metrics_generator_units" {
  description = "Number of Tempo worker units with metrics-generator role"
  type        = number
  default     = 3
}

variable "tempo_querier_units" {
  description = "Number of Tempo worker units with querier role"
  type        = number
  default     = 3
}
variable "tempo_query_frontend_units" {
  description = "Number of Tempo worker units with query-frontend role"
  type        = number
  default     = 3
}

variable "cloud" {
  description = "Kubernetes cloud or environment where this COS module will be deployed (e.g self-managed, aws)"
  type        = string
  default     = "self-managed"
}

# ssc doesn't have a "latest" track for ubuntu@24.04 base.
variable "ssc_channel" {
  description = "self-signed certificates charm channel."
  type        = string
  default     = "latest/edge"
}

```
Then, create a `aws.tfvars` file with the following content:

```hcl
cloud = "aws"
# If you're deploying on an ubuntu@24.04 base
ssc_channel  = "1/edge"
model        = "<model-name>"
s3_endpoint  = "<s3-endpoint>"
s3_access_key  = "<s3-access-key>"
s3_secret_key  = "<s3-secret-key>"
loki_bucket  = "<loki-bucket>"
mimir_bucket = "<mimir-bucket>"
tempo_bucket = "<tempo-bucket>"
```

Then, use terraform to deploy the module:
```bash
terraform init
terraform apply -var-file=aws.tfvars
```

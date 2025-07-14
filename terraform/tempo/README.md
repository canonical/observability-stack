# Terraform module for Tempo solution

This is a Terraform module facilitating the deployment of Tempo solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

The solution consists of the following Terraform modules:
- [tempo-coordinator-k8s](https://github.com/canonical/tempo-coordinator-k8s-operator): ingress, cluster coordination, single integration facade.
- [tempo-worker-k8s](https://github.com/canonical/tempo-worker-k8s-operator): run one or more tempo application components.
- [s3-integrator](https://github.com/canonical/s3-integrator): facade for S3 storage configurations.
- [self-signed-certificates](https://github.com/canonical/self-signed-certificates-operator): certificates operator to secure traffic with TLS.

This Terraform module deploys Tempo in its [microservices mode](https://grafana.com/docs/tempo/latest/setup/deployment/#microservices-mode), which runs each one of the required roles in distinct processes. [See](https://discourse.charmhub.io/t/topic/15484) to understand more about Tempo roles.


> [!NOTE]
> `s3-integrator` itself doesn't act as an S3 object storage system. For the solution to be functional, `s3-integrator` needs to point to an S3-like storage. See [this guide](https://discourse.charmhub.io/t/cos-lite-docs-set-up-minio/15211) to learn how to connect to an S3-like storage for traces.

## Requirements
This module requires a `juju` model to be available. Refer to the [usage section](#usage) below for more details.

## API

### Inputs
The module offers the following configurable inputs:

| Name | Type | Description | Default |
| - | - | - | - |
| `channel`| string | Channel that the charms are deployed from |  |
| `compactor_units`| number | Number of Tempo worker units with compactor role | 1 |
| `distributor_units`| number | Number of Tempo worker units with distributor role | 1 |
| `ingester_units`| number | Number of Tempo worker units with ingester role | 1 |
| `metrics_generator_units`| number | Number of Tempo worker units with metrics-generator role | 1 |
| `model`| string | Name of the model that the charm is deployed on |  |
| `querier_units`| number | Number of Tempo worker units with querier role | 1 |
| `query_frontend_units`| number | Number of Tempo worker units with query-frontend role | 1 |
| `coordinator_units`| number | Number of Tempo coordinator units | 1 |
| `s3_integrator_name` | string | Name of the s3-integrator app | 1 |
| `s3_bucket` | string | Name of the bucke in which Tempo stores traces | 1 |
| `s3_access_key` | string | Access key credential to connect to the S3 provider | 1 |
| `s3_secret_key` | string | Secret key credential to connect to the S3 provider | 1 |
| `s3_endpoint` | string | Endpoint of the S3 provider | 1 |


### Outputs
Upon application, the module exports the following outputs:

| Name | Type | Description |
| - | - | - |
| `app_names`| map(string) | Names of the deployed applications |
| `endpoints`| map(string) | Map of all `provides` and `requires` endpoints |

## Usage


### Basic usage

Users should ensure that Terraform is aware of the `juju_model` dependency of the charm module.

To deploy this module with its needed dependency, you can run `terraform apply -var="model=<MODEL_NAME>" -auto-approve`. This would deploy all Tempo components in the same model.

### Microservice deployment

By default, this Terraform module will deploy each Tempo worker with `1` unit. To configure the module to run `x` units of any worker role, you can run `terraform apply -var="model=<MODEL_NAME>" -var="<ROLE>_units=<x>" -auto-approve`.
See [Tempo worker roles](https://discourse.charmhub.io/t/tempo-worker-roles/15484) for the recommended scale for each role.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | >= 0.14.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anti_affinity"></a> [anti\_affinity](#input\_anti\_affinity) | Enable anti-affinity constraints | `bool` | `true` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | Channel that the charms are deployed from | `string` | n/a | yes |
| <a name="input_compactor_name"></a> [compactor\_name](#input\_compactor\_name) | Name of the Tempo compactor app | `string` | `"tempo-compactor"` | no |
| <a name="input_compactor_units"></a> [compactor\_units](#input\_compactor\_units) | Number of Tempo worker units with compactor role | `number` | `1` | no |
| <a name="input_coordinator_revision"></a> [coordinator\_revision](#input\_coordinator\_revision) | Revision number of the coordinator charm | `number` | `null` | no |
| <a name="input_coordinator_units"></a> [coordinator\_units](#input\_coordinator\_units) | Number of Tempo coordinator units | `number` | `1` | no |
| <a name="input_distributor_name"></a> [distributor\_name](#input\_distributor\_name) | Name of the Tempo distributor app | `string` | `"tempo-distributor"` | no |
| <a name="input_distributor_units"></a> [distributor\_units](#input\_distributor\_units) | Number of Tempo worker units with distributor role | `number` | `1` | no |
| <a name="input_ingester_name"></a> [ingester\_name](#input\_ingester\_name) | Name of the Tempo ingester app | `string` | `"tempo-ingester"` | no |
| <a name="input_ingester_units"></a> [ingester\_units](#input\_ingester\_units) | Number of Tempo worker units with ingester role | `number` | `1` | no |
| <a name="input_metrics_generator_name"></a> [metrics\_generator\_name](#input\_metrics\_generator\_name) | Name of the Tempo metrics-generator app | `string` | `"tempo-metrics-generator"` | no |
| <a name="input_metrics_generator_units"></a> [metrics\_generator\_units](#input\_metrics\_generator\_units) | Number of Tempo worker units with metrics-generator role | `number` | `1` | no |
| <a name="input_model"></a> [model](#input\_model) | Reference to an existing model resource or data source for the model to deploy to | `string` | n/a | yes |
| <a name="input_querier_name"></a> [querier\_name](#input\_querier\_name) | Name of the Tempo querier app | `string` | `"tempo-querier"` | no |
| <a name="input_querier_units"></a> [querier\_units](#input\_querier\_units) | Number of Tempo worker units with querier role | `number` | `1` | no |
| <a name="input_query_frontend_name"></a> [query\_frontend\_name](#input\_query\_frontend\_name) | Name of the Tempo query-frontend app | `string` | `"tempo-query-frontend"` | no |
| <a name="input_query_frontend_units"></a> [query\_frontend\_units](#input\_query\_frontend\_units) | Number of Tempo worker units with query-frontend role | `number` | `1` | no |
| <a name="input_s3_access_key"></a> [s3\_access\_key](#input\_s3\_access\_key) | S3 access-key credential | `string` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | Bucket name | `string` | `"tempo"` | no |
| <a name="input_s3_endpoint"></a> [s3\_endpoint](#input\_s3\_endpoint) | S3 endpoint | `string` | n/a | yes |
| <a name="input_s3_integrator_channel"></a> [s3\_integrator\_channel](#input\_s3\_integrator\_channel) | Channel that the s3-integrator charm is deployed from | `string` | `"2/edge"` | no |
| <a name="input_s3_integrator_name"></a> [s3\_integrator\_name](#input\_s3\_integrator\_name) | Name of the s3-integrator app | `string` | `"tempo-s3-integrator"` | no |
| <a name="input_s3_integrator_revision"></a> [s3\_integrator\_revision](#input\_s3\_integrator\_revision) | Revision number of the s3-integrator charm | `number` | `157` | no |
| <a name="input_s3_secret_key"></a> [s3\_secret\_key](#input\_s3\_secret\_key) | S3 secret-key credential | `string` | n/a | yes |
| <a name="input_worker_revision"></a> [worker\_revision](#input\_worker\_revision) | Revision number of the worker charm | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_names"></a> [app\_names](#output\_app\_names) | n/a |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | n/a |
<!-- END_TF_DOCS -->
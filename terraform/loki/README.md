# Terraform module for Loki solution

This is a Terraform module facilitating the deployment of Loki solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

The solution consists of the following Terraform modules:
- [loki-coordinator-k8s](https://github.com/canonical/loki-coordinator-k8s-operator): ingress, cluster coordination, single integration facade.
- [loki-worker-k8s](https://github.com/canonical/loki-worker-k8s-operator): run one or more Loki application components.
- [s3-integrator](https://github.com/canonical/s3-integrator): facade for S3 storage configurations.
- [self-signed-certificates](https://github.com/canonical/self-signed-certificates-operator): certificates operator to secure traffic with TLS.

This Terraform module deploys Loki in its [microservices mode](https://grafana.com/docs/enterprise-logs/latest/get-started/deployment-modes/#microservices-mode), which runs each one of the required roles in distinct processes.


> [!NOTE]
> `s3-integrator` itself doesn't act as an S3 object storage system. For the HA solution to be functional, `s3-integrator` needs to point to an S3-like storage. See [this guide](https://discourse.charmhub.io/t/cos-lite-docs-set-up-minio/15211) to learn how to connect to an S3-like storage for traces.

## Requirements
This module requires a `juju` model to be available. Refer to the [usage section](#usage) below for more details.

## API

### Inputs
The module offers the following configurable inputs:

| Name | Type | Description | Default |
| - | - | - | - |
| `backend_units`| number | Number of Loki worker units with the backend role | 1 |
| `channel`| string | Channel that the charms are deployed from |  |
| `model`| string | Name of the model that the charm is deployed on |  |
| `read_units`| number | Number of Loki worker units with the read role | 1 |
| `write_units`| number | Number of Loki worker units with the write role | 1 |
| `coordinator_units`| number | Number of Loki coordinator units | 1 |
| `s3_integrator_name` | string | Name of the s3-integrator app | 1 |
| `s3_bucket` | string | Name of the bucke in which Loki stores logs | 1 |
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

To deploy this module with its needed dependency, you can run `terraform apply -var="model=<MODEL_NAME>" -auto-approve`. This would deploy all Loki HA solution modules in the same model.

### Microservice deployment

By default, this Terraform module will deploy each Loki worker with `1` unit. To configure the module to run `x` units of any worker role, you can run `terraform apply -var="model=<MODEL_NAME>" -var="<ROLE>_units=<x>" -auto-approve`.
See [Loki worker roles](https://discourse.charmhub.io/t/loki-worker-roles/15484) for the recommended scale for each role.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | >= 0.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | >= 0.14.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_loki_backend"></a> [loki\_backend](#module\_loki\_backend) | git::https://github.com/canonical/loki-worker-k8s-operator//terraform | n/a |
| <a name="module_loki_coordinator"></a> [loki\_coordinator](#module\_loki\_coordinator) | git::https://github.com/canonical/loki-coordinator-k8s-operator//terraform | n/a |
| <a name="module_loki_read"></a> [loki\_read](#module\_loki\_read) | git::https://github.com/canonical/loki-worker-k8s-operator//terraform | n/a |
| <a name="module_loki_write"></a> [loki\_write](#module\_loki\_write) | git::https://github.com/canonical/loki-worker-k8s-operator//terraform | n/a |

## Resources

| Name | Type |
|------|------|
| [juju_access_secret.loki_s3_secret_access](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/access_secret) | resource |
| [juju_application.s3_integrator](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application) | resource |
| [juju_integration.coordinator_to_backend](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.coordinator_to_read](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.coordinator_to_s3_integrator](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_integration.coordinator_to_write](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/integration) | resource |
| [juju_secret.loki_s3_credentials_secret](https://registry.terraform.io/providers/juju/juju/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anti_affinity"></a> [anti\_affinity](#input\_anti\_affinity) | Enable anti-affinity constraints. | `bool` | `true` | no |
| <a name="input_backend_name"></a> [backend\_name](#input\_backend\_name) | Name of the Loki app with the backend role | `string` | `"loki-backend"` | no |
| <a name="input_backend_units"></a> [backend\_units](#input\_backend\_units) | Number of Loki worker units with the backend role | `number` | `1` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | Channel that the charms are deployed from | `string` | n/a | yes |
| <a name="input_coordinator_revision"></a> [coordinator\_revision](#input\_coordinator\_revision) | Revision number of the coordinator charm | `number` | `null` | no |
| <a name="input_coordinator_units"></a> [coordinator\_units](#input\_coordinator\_units) | Number of Loki coordinator units | `number` | `1` | no |
| <a name="input_model"></a> [model](#input\_model) | Reference to an existing model resource or data source for the model to deploy to | `string` | n/a | yes |
| <a name="input_read_name"></a> [read\_name](#input\_read\_name) | Name of the Loki app with the read role | `string` | `"loki-read"` | no |
| <a name="input_read_units"></a> [read\_units](#input\_read\_units) | Number of Loki worker units with the read role | `number` | `1` | no |
| <a name="input_s3_access_key"></a> [s3\_access\_key](#input\_s3\_access\_key) | S3 access-key credential | `string` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | Bucket name | `string` | `"loki"` | no |
| <a name="input_s3_endpoint"></a> [s3\_endpoint](#input\_s3\_endpoint) | S3 endpoint | `string` | n/a | yes |
| <a name="input_s3_integrator_channel"></a> [s3\_integrator\_channel](#input\_s3\_integrator\_channel) | Channel that the s3-integrator charm is deployed from | `string` | `"2/edge"` | no |
| <a name="input_s3_integrator_name"></a> [s3\_integrator\_name](#input\_s3\_integrator\_name) | Name of the s3-integrator app | `string` | `"loki-s3-integrator"` | no |
| <a name="input_s3_integrator_revision"></a> [s3\_integrator\_revision](#input\_s3\_integrator\_revision) | Revision number of the s3-integrator charm | `number` | `157` | no |
| <a name="input_s3_secret_key"></a> [s3\_secret\_key](#input\_s3\_secret\_key) | S3 secret-key credential | `string` | n/a | yes |
| <a name="input_worker_revision"></a> [worker\_revision](#input\_worker\_revision) | Revision number of the worker charm | `number` | `null` | no |
| <a name="input_write_name"></a> [write\_name](#input\_write\_name) | Name of the Loki app with the write role | `string` | `"loki-write"` | no |
| <a name="input_write_units"></a> [write\_units](#input\_write\_units) | Number of Loki worker units with the write role | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_names"></a> [app\_names](#output\_app\_names) | n/a |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | n/a |
<!-- END_TF_DOCS -->
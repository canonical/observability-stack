# Terraform module for Mimir solution

This is a Terraform module facilitating the deployment of Mimir solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs). This Terraform module deploys Mimir in its [microservices mode](https://grafana.com/docs/mimir/latest/references/architecture/deployment-modes/#microservices-mode), which runs each one of the required roles in distinct processes.

> [!NOTE]
> `s3-integrator` itself doesn't act as an S3 object storage system. For the HA solution to be functional, `s3-integrator` needs to point to an S3-like storage. See [this guide](https://discourse.charmhub.io/t/cos-lite-docs-set-up-minio/15211) to learn how to connect to an S3-like storage for traces.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | < 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | < 1.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mimir_backend"></a> [mimir\_backend](#module\_mimir\_backend) | git::https://github.com/canonical/mimir-worker-k8s-operator//terraform | tf-provider-v0 |
| <a name="module_mimir_coordinator"></a> [mimir\_coordinator](#module\_mimir\_coordinator) | git::https://github.com/canonical/mimir-coordinator-k8s-operator//terraform | tf-provider-v0 |
| <a name="module_mimir_read"></a> [mimir\_read](#module\_mimir\_read) | git::https://github.com/canonical/mimir-worker-k8s-operator//terraform | tf-provider-v0 |
| <a name="module_mimir_write"></a> [mimir\_write](#module\_mimir\_write) | git::https://github.com/canonical/mimir-worker-k8s-operator//terraform | tf-provider-v0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anti_affinity"></a> [anti\_affinity](#input\_anti\_affinity) | Enable anti-affinity constraints. | `bool` | `true` | no |
| <a name="input_backend_config"></a> [backend\_config](#input\_backend\_config) | Map of the backend worker configuration options | `map(string)` | `{}` | no |
| <a name="input_backend_name"></a> [backend\_name](#input\_backend\_name) | Name of the Mimir backend (meta role) app | `string` | `"mimir-backend"` | no |
| <a name="input_backend_units"></a> [backend\_units](#input\_backend\_units) | Number of Mimir worker units with the backend meta role | `number` | `1` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | Channel that the applications are deployed from | `string` | n/a | yes |
| <a name="input_coordinator_config"></a> [coordinator\_config](#input\_coordinator\_config) | Map of the coordinator configuration options | `map(string)` | `{}` | no |
| <a name="input_coordinator_constraints"></a> [coordinator\_constraints](#input\_coordinator\_constraints) | String listing constraints for the coordinator application | `string` | `"arch=amd64"` | no |
| <a name="input_coordinator_revision"></a> [coordinator\_revision](#input\_coordinator\_revision) | Revision number of the coordinator application | `number` | `null` | no |
| <a name="input_coordinator_storage_directives"></a> [coordinator\_storage\_directives](#input\_coordinator\_storage\_directives) | Map of storage used by the coordinator application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_coordinator_units"></a> [coordinator\_units](#input\_coordinator\_units) | Number of Mimir coordinator units | `number` | `1` | no |
| <a name="input_model"></a> [model](#input\_model) | Reference to an existing model resource or data source for the model to deploy to | `string` | n/a | yes |
| <a name="input_read_config"></a> [read\_config](#input\_read\_config) | Map of the read worker configuration options | `map(string)` | `{}` | no |
| <a name="input_read_name"></a> [read\_name](#input\_read\_name) | Name of the Mimir read (meta role) app | `string` | `"mimir-read"` | no |
| <a name="input_read_units"></a> [read\_units](#input\_read\_units) | Number of Mimir worker units with the read meta role | `number` | `1` | no |
| <a name="input_s3_access_key"></a> [s3\_access\_key](#input\_s3\_access\_key) | S3 access-key credential | `string` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | Bucket name | `string` | `"mimir"` | no |
| <a name="input_s3_endpoint"></a> [s3\_endpoint](#input\_s3\_endpoint) | S3 endpoint | `string` | n/a | yes |
| <a name="input_s3_integrator_channel"></a> [s3\_integrator\_channel](#input\_s3\_integrator\_channel) | Channel that the s3-integrator application is deployed from | `string` | `"2/edge"` | no |
| <a name="input_s3_integrator_config"></a> [s3\_integrator\_config](#input\_s3\_integrator\_config) | Map of the s3-integrator configuration options | `map(string)` | `{}` | no |
| <a name="input_s3_integrator_constraints"></a> [s3\_integrator\_constraints](#input\_s3\_integrator\_constraints) | String listing constraints for the s3-integrator application | `string` | `"arch=amd64"` | no |
| <a name="input_s3_integrator_name"></a> [s3\_integrator\_name](#input\_s3\_integrator\_name) | Name of the s3-integrator app | `string` | `"mimir-s3-integrator"` | no |
| <a name="input_s3_integrator_revision"></a> [s3\_integrator\_revision](#input\_s3\_integrator\_revision) | Revision number of the s3-integrator application | `number` | `null` | no |
| <a name="input_s3_integrator_storage_directives"></a> [s3\_integrator\_storage\_directives](#input\_s3\_integrator\_storage\_directives) | Map of storage used by the s3-integrator application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_s3_integrator_units"></a> [s3\_integrator\_units](#input\_s3\_integrator\_units) | Number of S3 integrator units | `number` | `1` | no |
| <a name="input_s3_secret_key"></a> [s3\_secret\_key](#input\_s3\_secret\_key) | S3 secret-key credential | `string` | n/a | yes |
| <a name="input_worker_constraints"></a> [worker\_constraints](#input\_worker\_constraints) | String listing constraints for the worker application | `string` | `"arch=amd64"` | no |
| <a name="input_worker_revision"></a> [worker\_revision](#input\_worker\_revision) | Revision number of the worker application | `number` | `null` | no |
| <a name="input_worker_storage_directives"></a> [worker\_storage\_directives](#input\_worker\_storage\_directives) | Map of storage used by the worker application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_write_config"></a> [write\_config](#input\_write\_config) | Map of the write worker configuration options | `map(string)` | `{}` | no |
| <a name="input_write_name"></a> [write\_name](#input\_write\_name) | Name of the Mimir write (meta role) app | `string` | `"mimir-write"` | no |
| <a name="input_write_units"></a> [write\_units](#input\_write\_units) | Number of Mimir worker units with the write meta role | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_names"></a> [app\_names](#output\_app\_names) | All application names which make up this product module |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | All Juju integration endpoints which make up this product module |
<!-- END_TF_DOCS -->

## Usage

### Basic usage

Users should ensure that Terraform is aware of the `juju_model` dependency of the charm module.

To deploy this module with its needed dependency, you can run `terraform apply -var="model=<MODEL_NAME>" -auto-approve`. This would deploy all Mimir HA solution modules in the same model.

### Microservice deployment

By default, this Terraform module will deploy each Mimir worker with `1` unit. To configure the module to run `x` units of any worker role, you can run `terraform apply -var="model=<MODEL_NAME>" -var="<ROLE>_units=<x>" -auto-approve`.
See [Mimir worker roles](https://discourse.charmhub.io/t/mimir-worker-roles/15484) for the recommended scale for each role.

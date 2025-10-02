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
| <a name="module_tempo_compactor"></a> [tempo\_compactor](#module\_tempo\_compactor) | git::https://github.com/canonical/tempo-worker-k8s-operator//terraform | n/a |
| <a name="module_tempo_coordinator"></a> [tempo\_coordinator](#module\_tempo\_coordinator) | git::https://github.com/canonical/tempo-coordinator-k8s-operator//terraform | n/a |
| <a name="module_tempo_distributor"></a> [tempo\_distributor](#module\_tempo\_distributor) | git::https://github.com/canonical/tempo-worker-k8s-operator//terraform | n/a |
| <a name="module_tempo_ingester"></a> [tempo\_ingester](#module\_tempo\_ingester) | git::https://github.com/canonical/tempo-worker-k8s-operator//terraform | n/a |
| <a name="module_tempo_metrics_generator"></a> [tempo\_metrics\_generator](#module\_tempo\_metrics\_generator) | git::https://github.com/canonical/tempo-worker-k8s-operator//terraform | n/a |
| <a name="module_tempo_querier"></a> [tempo\_querier](#module\_tempo\_querier) | git::https://github.com/canonical/tempo-worker-k8s-operator//terraform | n/a |
| <a name="module_tempo_query_frontend"></a> [tempo\_query\_frontend](#module\_tempo\_query\_frontend) | git::https://github.com/canonical/tempo-worker-k8s-operator//terraform | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anti_affinity"></a> [anti\_affinity](#input\_anti\_affinity) | Enable anti-affinity constraints | `bool` | `true` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | Channel that the applications are deployed from | `string` | n/a | yes |
| <a name="input_compactor_config"></a> [compactor\_config](#input\_compactor\_config) | Map of the compactor worker configuration options | `map(string)` | `{}` | no |
| <a name="input_compactor_name"></a> [compactor\_name](#input\_compactor\_name) | Name of the Tempo compactor app | `string` | `"tempo-compactor"` | no |
| <a name="input_compactor_units"></a> [compactor\_units](#input\_compactor\_units) | Number of Tempo worker units with compactor role | `number` | `1` | no |
| <a name="input_coordinator_config"></a> [coordinator\_config](#input\_coordinator\_config) | Map of the coordinator configuration options | `map(string)` | `{}` | no |
| <a name="input_coordinator_constraints"></a> [coordinator\_constraints](#input\_coordinator\_constraints) | String listing constraints for the coordinator application | `string` | `"arch=amd64"` | no |
| <a name="input_coordinator_revision"></a> [coordinator\_revision](#input\_coordinator\_revision) | Revision number of the coordinator application | `number` | `null` | no |
| <a name="input_coordinator_storage_directives"></a> [coordinator\_storage\_directives](#input\_coordinator\_storage\_directives) | Map of storage used by the coordinator application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_coordinator_units"></a> [coordinator\_units](#input\_coordinator\_units) | Number of Tempo coordinator units | `number` | `1` | no |
| <a name="input_distributor_config"></a> [distributor\_config](#input\_distributor\_config) | Map of the distributor worker configuration options | `map(string)` | `{}` | no |
| <a name="input_distributor_name"></a> [distributor\_name](#input\_distributor\_name) | Name of the Tempo distributor app | `string` | `"tempo-distributor"` | no |
| <a name="input_distributor_units"></a> [distributor\_units](#input\_distributor\_units) | Number of Tempo worker units with distributor role | `number` | `1` | no |
| <a name="input_ingester_config"></a> [ingester\_config](#input\_ingester\_config) | Map of the ingester worker configuration options | `map(string)` | `{}` | no |
| <a name="input_ingester_name"></a> [ingester\_name](#input\_ingester\_name) | Name of the Tempo ingester app | `string` | `"tempo-ingester"` | no |
| <a name="input_ingester_units"></a> [ingester\_units](#input\_ingester\_units) | Number of Tempo worker units with ingester role | `number` | `1` | no |
| <a name="input_metrics_generator_config"></a> [metrics\_generator\_config](#input\_metrics\_generator\_config) | Map of the metrics-generator worker configuration options | `map(string)` | `{}` | no |
| <a name="input_metrics_generator_name"></a> [metrics\_generator\_name](#input\_metrics\_generator\_name) | Name of the Tempo metrics-generator app | `string` | `"tempo-metrics-generator"` | no |
| <a name="input_metrics_generator_units"></a> [metrics\_generator\_units](#input\_metrics\_generator\_units) | Number of Tempo worker units with metrics-generator role | `number` | `1` | no |
| <a name="input_model"></a> [model](#input\_model) | Reference to an existing model resource or data source for the model to deploy to | `string` | n/a | yes |
| <a name="input_querier_config"></a> [querier\_config](#input\_querier\_config) | Map of the querier worker configuration options | `map(string)` | `{}` | no |
| <a name="input_querier_name"></a> [querier\_name](#input\_querier\_name) | Name of the Tempo querier app | `string` | `"tempo-querier"` | no |
| <a name="input_querier_units"></a> [querier\_units](#input\_querier\_units) | Number of Tempo worker units with querier role | `number` | `1` | no |
| <a name="input_query_frontend_config"></a> [query\_frontend\_config](#input\_query\_frontend\_config) | Map of the query-frontend worker configuration options | `map(string)` | `{}` | no |
| <a name="input_query_frontend_name"></a> [query\_frontend\_name](#input\_query\_frontend\_name) | Name of the Tempo query-frontend app | `string` | `"tempo-query-frontend"` | no |
| <a name="input_query_frontend_units"></a> [query\_frontend\_units](#input\_query\_frontend\_units) | Number of Tempo worker units with query-frontend role | `number` | `1` | no |
| <a name="input_s3_access_key"></a> [s3\_access\_key](#input\_s3\_access\_key) | S3 access-key credential | `string` | n/a | yes |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | Bucket name | `string` | `"tempo"` | no |
| <a name="input_s3_endpoint"></a> [s3\_endpoint](#input\_s3\_endpoint) | S3 endpoint | `string` | n/a | yes |
| <a name="input_s3_integrator_channel"></a> [s3\_integrator\_channel](#input\_s3\_integrator\_channel) | Channel that the s3-integrator application is deployed from | `string` | `"2/edge"` | no |
| <a name="input_s3_integrator_config"></a> [s3\_integrator\_config](#input\_s3\_integrator\_config) | Map of the s3-integrator configuration options | `map(string)` | `{}` | no |
| <a name="input_s3_integrator_constraints"></a> [s3\_integrator\_constraints](#input\_s3\_integrator\_constraints) | String listing constraints for the s3-integrator application | `string` | `"arch=amd64"` | no |
| <a name="input_s3_integrator_name"></a> [s3\_integrator\_name](#input\_s3\_integrator\_name) | Name of the s3-integrator app | `string` | `"tempo-s3-integrator"` | no |
| <a name="input_s3_integrator_revision"></a> [s3\_integrator\_revision](#input\_s3\_integrator\_revision) | Revision number of the s3-integrator application | `number` | `157` | no |
| <a name="input_s3_integrator_storage_directives"></a> [s3\_integrator\_storage\_directives](#input\_s3\_integrator\_storage\_directives) | Map of storage used by the s3-integrator application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_s3_integrator_units"></a> [s3\_integrator\_units](#input\_s3\_integrator\_units) | Number of S3 integrator units | `number` | `1` | no |
| <a name="input_s3_secret_key"></a> [s3\_secret\_key](#input\_s3\_secret\_key) | S3 secret-key credential | `string` | n/a | yes |
| <a name="input_worker_constraints"></a> [worker\_constraints](#input\_worker\_constraints) | String listing constraints for the worker application | `string` | `"arch=amd64"` | no |
| <a name="input_worker_revision"></a> [worker\_revision](#input\_worker\_revision) | Revision number of the worker application | `number` | `null` | no |
| <a name="input_worker_storage_directives"></a> [worker\_storage\_directives](#input\_worker\_storage\_directives) | Map of storage used by the worker application, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_names"></a> [app\_names](#output\_app\_names) | All application names which make up this product module |
| <a name="output_endpoints"></a> [endpoints](#output\_endpoints) | All Juju integration endpoints which make up this product module |
<!-- END_TF_DOCS -->
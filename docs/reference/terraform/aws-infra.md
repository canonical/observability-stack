<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cos_cloud_name"></a> [cos\_cloud\_name](#input\_cos\_cloud\_name) | The name to assign to the Kubernetes cloud when running 'juju add-k8s'. | `string` | `"cos-cloud"` | no |
| <a name="input_cos_controller_name"></a> [cos\_controller\_name](#input\_cos\_controller\_name) | The name to assign to the Juju controller that will manage COS. | `string` | `"cos-controller"` | no |
| <a name="input_cos_model_name"></a> [cos\_model\_name](#input\_cos\_model\_name) | The name of the Juju model where COS will be deployed. | `string` | `"cos"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where the resources will be provisioned. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cos_model"></a> [cos\_model](#output\_cos\_model) | n/a |
| <a name="output_loki_bucket"></a> [loki\_bucket](#output\_loki\_bucket) | n/a |
| <a name="output_mimir_bucket"></a> [mimir\_bucket](#output\_mimir\_bucket) | n/a |
| <a name="output_s3_access_key"></a> [s3\_access\_key](#output\_s3\_access\_key) | n/a |
| <a name="output_s3_endpoint"></a> [s3\_endpoint](#output\_s3\_endpoint) | n/a |
| <a name="output_s3_secret_key"></a> [s3\_secret\_key](#output\_s3\_secret\_key) | n/a |
| <a name="output_tempo_bucket"></a> [tempo\_bucket](#output\_tempo\_bucket) | n/a |
<!-- END_TF_DOCS -->
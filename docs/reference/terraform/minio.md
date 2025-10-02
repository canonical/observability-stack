<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_juju"></a> [juju](#requirement\_juju) | ~> 0.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | ~> 0.14 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_channel"></a> [channel](#input\_channel) | Charms channel | `string` | `"latest/edge"` | no |
| <a name="input_loki"></a> [loki](#input\_loki) | Configuration outputs from the Loki module, including bucket and integrator details. | `any` | n/a | yes |
| <a name="input_mc_binary_url"></a> [mc\_binary\_url](#input\_mc\_binary\_url) | mc binary URL | `string` | `"https://dl.min.io/client/mc/release/linux-amd64/mc"` | no |
| <a name="input_mimir"></a> [mimir](#input\_mimir) | Configuration outputs from the Mimir module, including bucket and integrator details. | `any` | n/a | yes |
| <a name="input_minio_app"></a> [minio\_app](#input\_minio\_app) | Minio user | `string` | `"minio"` | no |
| <a name="input_minio_password"></a> [minio\_password](#input\_minio\_password) | Minio Password | `string` | n/a | yes |
| <a name="input_minio_user"></a> [minio\_user](#input\_minio\_user) | Minio user | `string` | n/a | yes |
| <a name="input_model"></a> [model](#input\_model) | Model name | `string` | n/a | yes |
| <a name="input_tempo"></a> [tempo](#input\_tempo) | Configuration outputs from the Tempo module, including bucket and integrator details. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_minio_name"></a> [minio\_name](#output\_minio\_name) | The application name for Minio |
<!-- END_TF_DOCS -->
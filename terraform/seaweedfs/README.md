# Terraform module for seaweedfs-k8s

This is a Terraform module facilitating the deployment of the [seaweedfs-k8s](https://charmhub.io/seaweedfs-k8s) charm, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_juju"></a> [juju](#provider\_juju) | ~> 1.0 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application name for the SeaweedFS deployment | `string` | `"seaweedfs"` | no |
| <a name="input_channel"></a> [channel](#input\_channel) | Channel that SeaweedFS is deployed from | `string` | `"latest/edge"` | no |
| <a name="input_config"></a> [config](#input\_config) | Map of SeaweedFS configuration options | `map(string)` | `{}` | no |
| <a name="input_constraints"></a> [constraints](#input\_constraints) | String listing constraints for the SeaweedFS application | `string` | `"arch=amd64"` | no |
| <a name="input_model_uuid"></a> [model\_uuid](#input\_model\_uuid) | Reference to an existing model resource or data source for the model to deploy to | `string` | n/a | yes |
| <a name="input_revision"></a> [revision](#input\_revision) | Revision number of the SeaweedFS application | `number` | `null` | no |
| <a name="input_storage_directives"></a> [storage\_directives](#input\_storage\_directives) | Map of storage used by SeaweedFS, which defaults to 1 GB, allocated by Juju | `map(string)` | `{}` | no |
| <a name="input_units"></a> [units](#input\_units) | Number of SeaweedFS units | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_name"></a> [app\_name](#output\_app\_name) | The name of the deployed SeaweedFS application |
| <a name="output_provides"></a> [provides](#output\_provides) | All Juju integration endpoints where the charm is the provider |
| <a name="output_requires"></a> [requires](#output\_requires) | All Juju integration endpoints where the charm is the requirer |
<!-- END_TF_DOCS -->

## Usage

To deploy seaweedfs-k8s in a model named `storage`, create this root module:

```hcl
terraform {
  required_version = ">= 1.7"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

resource "juju_model" "storage" {
  name = "storage"
}

module "seaweedfs" {
  source     = "git::https://github.com/canonical/observability-stack//terraform/seaweedfs"
  model_uuid = juju_model.storage.uuid
}
```

Then, use terraform to deploy the module:

```shell
terraform init
terraform apply
```

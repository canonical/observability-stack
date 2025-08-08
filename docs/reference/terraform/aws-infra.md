# From Zero to COS: AWS Provisioning & Deployment

This directory contains Terraform modules for automating the process of bootstrapping a fresh AWS account to a fully running instance of COS deployed on a 3-node EKS cluster.

## Prerequisites

Make sure you have the following installed:

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) >= v1.10.4
- [AWS CLI](https://github.com/aws/aws-cli) >= 2.26.7
- [Juju](https://snapcraft.io/juju) >= 3.0.3
- [Just](https://github.com/casey/just) >= 1.40.0

### AWS Credentials Setup

Before running any commands, ensure your AWS credentials are configured on the host:

You can do this using one of the following methods:

- [Environment variables](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html)
- [Credentials file](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-files.html)

---

## Usage

### Bootstrap AWS infrastructure + Juju controller:
In order to provision the AWS infrastructure required for COS, create a `main.tf` file with the following content.

```hcl
module "aws_infra" {
  source              = "git::https://github.com/canonical/observability-stack//terraform/aws-infra"
  region              = var.region
  cos_cloud_name      = var.cos_cloud_name
  cos_controller_name = var.cos_controller_name
  cos_model_name      = var.cos_model_name
}

variable "region" {
  description = "The AWS region where the resources will be provisioned."
  type        = string
}

variable "cos_cloud_name" {
  description = "The name to assign to the Kubernetes cloud when running 'juju add-k8s'."
  type        = string
  default     = "cos-cloud"
}

variable "cos_controller_name" {
  description = "The name to assign to the Juju controller that will manage COS."
  type        = string
  default     = "cos-controller"
}

variable "cos_model_name" {
  description = "The name of the Juju model where COS will be deployed."
  type        = string
  default     = "cos"
}

```
Then, create a `terraform.tfvars` file with the following content:

```hcl
region              = "<aws-region>"
cos_cloud_name      = "<cos-cloud-name>"
cos_controller_name = "<cos-controller-name>"
cos_model_name      = "<cos-model-name>"
```
Then, use terraform to deploy the module:
```bash
terraform init
terraform apply -var-file=terraform.tfvars
```
### Full bootstrap: go from zero to COS:

You can fully bootstrap AWS infra and COS in one of two ways:
#### Option 1: Manual 2-Step Process
1. [Bootstrap AWS infra](#bootstrap-aws-infrastructure--juju-controller) 

Set up the necessary infrastructure and Juju controller on AWS using the `aws-infra` module.

2. [Deploy COS on the freshly created infra](../cos/README.md#deploy-cos-on-aws-eks)

Use the output from step 1 to deploy COS on top of your provisioned infrastructure using the `cos` module.

#### Option 2: Automated via `just`

Clone this repository and run the appropriate `just` command to fully automate the bootstrap process.
This command handles:

1. Bootstrapping the AWS infrastructure
2. Piping all required input to deploy COS on top


Create a `terraform.tfvars` file with the following content:
```hcl
region = "<your-aws-region>"
# Add other optional variables below
cos_cloud_name = "<cos_cloud_name>"
cos_controller_name = "<cos_controller_name>"
cos_model_name = "<cos_model_name>"
```
Then, run `just apply`

---

## Available Commands (via `just`)

- `just init` – Initialize Terraform for AWS infra and COS
- `just apply` – Provision AWS infrastructure, then pipe the necessary outputs to provision COS on top
- `just destroy` – Tear down everything (COS + infra)

---

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
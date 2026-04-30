# Terraform module for the COS Dev solution

This is a Terraform module facilitating the deployment of the COS Dev solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs). This Terraform module deploys a lightweight COS stack, where Loki, Mimir and Tempo each run as a single unit with the `-all` role (monolithic mode), backed by [SeaweedFS](https://github.com/seaweedfs/seaweedfs) as the built-in S3 storage backend.

This module is intended for development and testing environments where full HA is not required. It uses the individual coordinator and worker charm modules, rather than the bundled operator modules used by the main COS module.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

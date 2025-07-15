# Terraform module for Loki solution

This is a Terraform module facilitating the deployment of Loki solution, using the [Terraform juju provider](https://github.com/juju/terraform-provider-juju/). For more information, refer to the provider [documentation](https://registry.terraform.io/providers/juju/juju/latest/docs).This Terraform module deploys Loki in its [microservices mode](https://grafana.com/docs/enterprise-logs/latest/get-started/deployment-modes/#microservices-mode), which runs each one of the required roles in distinct processes.

> [!NOTE]
> `s3-integrator` itself doesn't act as an S3 object storage system. For the HA solution to be functional, `s3-integrator` needs to point to an S3-like storage. See [this guide](https://discourse.charmhub.io/t/cos-lite-docs-set-up-minio/15211) to learn how to connect to an S3-like storage for traces.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Usage

### Basic usage

Users should ensure that Terraform is aware of the `juju_model` dependency of the charm module.

To deploy this module with its needed dependency, you can run `terraform apply -var="model=<MODEL_NAME>" -auto-approve`. This would deploy all Loki HA solution modules in the same model.

### Microservice deployment

By default, this Terraform module will deploy each Loki worker with `1` unit. To configure the module to run `x` units of any worker role, you can run `terraform apply -var="model=<MODEL_NAME>" -var="<ROLE>_units=<x>" -auto-approve`.
See [Loki worker roles](https://discourse.charmhub.io/t/loki-worker-roles/15484) for the recommended scale for each role.

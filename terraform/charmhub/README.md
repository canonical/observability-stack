# Terraform module for the COS solution

This Terraform module computes a charm’s latest revision (from a channel and base) using the CharmHub API.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | ~> 3.0 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architecture"></a> [architecture](#input\_architecture) | Architecture (e.g., amd64, arm64) | `string` | `"amd64"` | no |
| <a name="input_base"></a> [base](#input\_base) | Base Ubuntu (e.g., ubuntu@22.04, ubuntu@24.04) | `string` | n/a | yes |
| <a name="input_channel"></a> [channel](#input\_channel) | Channel name (e.g., 14/stable, 16/edge) | `string` | n/a | yes |
| <a name="input_charm"></a> [charm](#input\_charm) | Name of the charm (e.g., postgresql) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_charm_revision"></a> [charm\_revision](#output\_charm\_revision) | The revision number for the specified charm channel and base |
<!-- END_TF_DOCS -->

## Usage

This example defines and provides multiple charm names to the `charmhubs` module. This module then
computes the latest revision in the specified channel e.g., `2/stable`. Finally, it creates
`juju_application.apps` with the computed revisions.

```hcl
terraform {
  required_providers {
    juju = {
      source = "juju/juju"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

locals {
  channel = "2/stable"
  base    = "ubuntu@24.04"

  charms = {
    alertmanager = "alertmanager-k8s"
    prometheus   = "prometheus-k8s"
    grafana      = "grafana-k8s"
  }
}

module "charmhubs" {
  source   = "../charmhub"
  for_each = local.charms

  charm        = each.value
  channel      = local.channel
  base         = local.base
  architecture = "amd64"
}

resource "juju_model" "development" {
  name = "development"
}

resource "juju_application" "apps" {
  for_each = local.charms

  model_uuid = juju_model.development.uuid
  trust    = true

  charm {
    name     = each.value
    channel  = local.channel
    revision = module.charmhubs[each.key].charm_revision
    base     = local.base
  }
}
```

terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

resource "juju_model" "cos" { name = "cos-lite" }

module "cos-lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model_uuid   = juju_model.cos.uuid
  risk         = "edge"
  internal_tls = false
}

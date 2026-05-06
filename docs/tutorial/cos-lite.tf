terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

resource "juju_model" "cos_lite" {
  name = "cos-lite"
}

module "cos-lite" {
  source     = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=main"
  model_uuid = juju_model.cos_lite.uuid
  risk    = "edge"
}

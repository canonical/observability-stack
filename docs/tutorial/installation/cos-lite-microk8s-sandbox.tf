terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

resource "juju_model" "cos" {
  name   = "cos"
  config = { logging-config = "<root>=WARNING; unit=DEBUG" }
}

module "cos-lite" {
  source     = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model_uuid = juju_model.cos.uuid
  channel    = "1/stable"
  ssc        = { channel = "1/stable" }
  traefik    = { channel = "latest/edge" }
}

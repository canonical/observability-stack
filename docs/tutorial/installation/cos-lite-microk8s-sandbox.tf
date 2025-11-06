terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

data "juju_model" "my-model" {
  name  = "cos"
  owner = "admin"
}

module "cos-lite" {
  source     = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model_uuid = data.juju_model.my-model.uuid
  channel    = "1/stable"
  ssc        = { channel = "1/stable" }
  traefik    = { channel = "latest/edge" }
}

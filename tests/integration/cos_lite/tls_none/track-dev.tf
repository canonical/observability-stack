terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

variable "model" {
  type = string
}

data "juju_model" "model" {
  name  = var.model
  owner = "admin"
}

module "cos-lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model_uuid   = data.juju_model.model.uuid
  channel      = "dev/edge"
  internal_tls = "false"

  traefik           = { channel = "latest/edge" }  # TODO: Switch to latest/stable when rev257 hits stable
}

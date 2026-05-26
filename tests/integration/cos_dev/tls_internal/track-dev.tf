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

module "cos-dev" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-dev"
  model_uuid   = data.juju_model.model.uuid
  risk         = "edge"
  internal_tls = true
}

terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

variable "model" { type = string }
data "juju_model" "cos" {
  name  = var.model
  owner = "admin"
}

# [docs:cos-lite]
module "cos-lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=fix/remove-traefik-patch"
  model_uuid   = data.juju_model.cos.uuid
  risk         = "edge"
  internal_tls = true
}

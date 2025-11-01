terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

variable "ca_model" {
  type = string
}

variable "cos_model" {
  type = string
}

data "juju_model" "ca-model" {
  name  = var.ca_model
  owner = "admin"
}

data "juju_model" "cos-model" {
  name  = var.cos_model
  owner = "admin"
}

module "ssc" {
  source     = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  model_uuid = data.juju_model.ca-model.uuid
}

module "cos-lite" {
  source                          = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model_uuid                      = data.juju_model.cos-model.uuid
  channel                         = "2/edge"
  internal_tls                    = "false"
  external_certificates_offer_url = module.ssc.offers.certificates.url

  traefik           = { channel = "latest/edge" }  # TODO: Switch to latest/stable when rev257 hits stable
}

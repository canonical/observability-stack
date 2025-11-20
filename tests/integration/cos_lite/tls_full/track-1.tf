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
  source                          = "../../../../terraform/cos-lite"
  model_uuid                      = data.juju_model.cos-model.uuid
  channel                         = "dev/edge"
  internal_tls                    = "true"
  external_certificates_offer_url = "admin/${var.ca_model}.certificates"
  external_ca_cert_offer_url      = "admin/${var.ca_model}.send-ca-cert"

  traefik           = { channel = "latest/edge" }  # TODO: Switch to latest/stable when rev257 hits stable
  grafana           = { revision = 173 }
}

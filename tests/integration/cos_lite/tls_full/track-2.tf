terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

variable "ca_model" { type = string }
variable "cos_model" { type = string }

data "juju_model" "ca" {
  name  = var.ca_model
  owner = "admin"
}

data "juju_model" "cos" {
  name  = var.cos_model
  owner = "admin"
}

module "ssc" {
  source     = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  model_uuid = data.juju_model.ca.uuid
}

module "cos-lite" {
  source                          = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=fix/remove-traefik-patch-track-2"
  model_uuid                      = data.juju_model.cos.uuid
  channel                         = "2/stable"
  internal_tls                    = true
  external_certificates_offer_url = "admin/${var.ca_model}.certificates"
  external_ca_cert_offer_url      = "admin/${var.ca_model}.send-ca-cert"
}


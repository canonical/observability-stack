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
  source     = "git::https://github.com/MichaelThamm/self-signed-certificates-operator//terraform"
  model_uuid = data.juju_model.ca-model.uuid
}

module "cos-lite" {
  source                          = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=feat/tf-provider-v1"
  model_uuid                      = data.juju_model.cos-model.uuid
  channel                         = "2/edge"
  internal_tls                    = "true"
  external_certificates_offer_url = module.ssc.offers.certificates.url
}


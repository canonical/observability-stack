terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0"
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
  source                          = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=track/3.0"
  model                           = { uuid = data.juju_model.cos-model.uuid }
  risk                            = "stable"
  internal_tls                    = true
  external_certificates_offer_url = "admin/${var.ca_model}.certificates"
  external_ca_cert_offer_url      = "admin/${var.ca_model}.send-ca-cert"

  # The offer URLs must stay static strings so count/for_each in the module
  # remain known at plan time. depends_on guarantees the CA model's offers are
  # created before COS consumes them, without introducing apply-time-unknowns.
  depends_on = [module.ssc]
}

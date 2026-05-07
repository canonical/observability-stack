terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

resource "juju_model" "ca" { name = "ca" }
resource "juju_model" "cos" { name = "cos-lite" }

module "ssc" {
  source     = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  model_uuid = juju_model.ca.uuid
}

module "cos-lite" {
  source                          = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=fix/remove-traefik-patch-track-2"
  model_uuid                      = juju_model.cos.uuid
  channel                         = "2/stable"
  internal_tls                    = true
  external_certificates_offer_url = "admin/${juju_model.ca.name}.certificates"
  external_ca_cert_offer_url      = "admin/${juju_model.ca.name}.send-ca-cert"
}


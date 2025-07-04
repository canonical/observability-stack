# jam cos
# jam external-ca
# tfa -target module.ssc  # since the traefik:receive-ca-cert integration depends on module.ssc
# tfa

terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.14.0"
    }
  }
}

module "ssc" {
  source   = "git::https://github.com/MichaelThamm/self-signed-certificates-operator//terraform?ref=feat/tf-output-offers"
  model    = "external-ca"
}

module "cos-lite" {
  source                = "../cos-lite" 
  model                 = "cos"
  channel               = "1/stable"
  traefik_channel       = "latest/edge"
  external_certificates_offer_url = module.ssc.offers.certificates.url
}

# resource "juju_integration" "manual_ca_to_traefik" {
#   model = "cos"

#   application {
#     name     = module.cos-lite.components.traefik.app_name
#     endpoint = module.cos-lite.components.traefik.endpoints.receive-ca-cert
#   }

#   application {
#     offer_url = module.ssc.provides.send-ca-cert.url  # local.ssc_offer_url
#   }
# }

# resource "juju_integration" "manual_ca_to_traefik" {
#   model = "cos"

#   application {
#     name     = module.cos-lite.components.traefik.app_name
#     endpoint = module.cos-lite.components.traefik.endpoints.receive-ca-cert
#   }

#   application {
#     offer_url = module.ssc.provides.send-ca-cert.url  # local.ssc_offer_url
#   }
# }

# TODO
# - Document





output "url" {
  value = module.ssc.offers.certificates.url
}

output "traefik" {
  value = module.cos-lite.components.traefik.endpoints.receive_ca_cert
}

# -------------- # Other TLS methods --------------

# module "manual" {
#   source   = "git::https://github.com/MichaelThamm/self-signed-certificates-operator//terraform?ref=feat/tf-output-offers"
#   model    = "external-ca"
# }

# # manual-tls-certs
# resource "juju_integration" "manual_ca_to_traefik" {
#   model = "external-ca"

#   application {
#     name     = module.cos-lite.components.traefik.app_name
#     endpoint = module.cos-lite.components.traefik.endpoints.receive-ca-cert
#   }

#   application {
#     offer_url = module.manual.offers.send-ca-cert.url  # local.ssc_offer_url
#   }
# }

# https://github.com/canonical/lego-operator
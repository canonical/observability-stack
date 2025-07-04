# Note: The deployment order matters since the 'traefik:certificates' integration depends on 'module.ssc'
#   'terraform apply -target module.ssc'
#   'terraform apply'

module "ssc" {
  source = "git::https://github.com/MichaelThamm/self-signed-certificates-operator//terraform?ref=feat/tf-output-offers"  # FIXME
  model  = "external-ca"
}

module "cos-lite" {
  source                          = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=feat/tls-termination"  # FIXME ../cos-lite
  model                           = "cos"
  channel                         = "1/stable"
  traefik_channel                 = "latest/edge"
  internal_tls                    = true  # Set to 'false' to disable inter-model TLS
  external_certificates_offer_url = module.ssc.offers.certificates.url  # Set to 'null' or remove this line to communicate with Traefik via HTTP
}

# TODO can I omit the provider instantiation since this is not a tutorial?
terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.14.0"
    }
  }
}

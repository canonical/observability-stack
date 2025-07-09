# Note: The deployment order matters since the 'traefik:certificates' integration depends on 'module.ssc'
#   'terraform apply -target module.ssc'
#   'terraform apply'

module "ssc" {
  source = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  model  = "external-ca"
}

module "cos" {
  # Use the right source value depending on whether you are using cos or cos-lite
  source                          = "git::https://github.com/canonical/observability-stack//terraform/cos"
  model                           = "cos"
  channel                         = "1/stable"
  traefik_channel                 = "latest/edge"
  internal_tls                    = true  # Set to 'false' to disable TLS between in-model applications
  external_certificates_offer_url = module.ssc.offers.certificates.url  # Set to 'null' to communicate with Traefik via HTTP, i.e. 'external_tls'
}

resource "juju_model" "cos" {
  name = "cos"
}

module "cos" {
  # Use the right source value depending on whether you are using cos or cos-lite
  source                          = "git::https://github.com/canonical/observability-stack//terraform/cos?ref=track/2"
  model_uuid                      = juju_model.cos.uuid
  channel                         = "2/stable"
  internal_tls                    = true # TLS between in-model applications
  
  # Update the _offer_url inputs with the offered endpoints of the external CA's model
  external_certificates_offer_url = "admin/external-ca-model.certificates" # Set to 'null' to communicate with Traefik via HTTP, i.e. no 'external_tls'
  external_ca_cert_offer_url      = "admin/external-ca-model.send-ca-cert" # Required if 'external_certificates_offer_url' is set
}

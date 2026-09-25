module "cos" {
  # Use the right source value depending on whether you are using cos or cos-lite
  source = "git::https://github.com/canonical/observability-stack//terraform/cos?ref=main"

  # ... other inputs ...

  internal_tls = true # TLS between in-model applications

  # Update the _offer_url inputs with the offered endpoints of the external CA's model.
  # Offers are opt-in and named <app_name>-<endpoint>, enabled on the CA module like so
  # offered_endpoints = ["certificates", "send-ca-cert"] (app_name "self-signed-certificates" below).
  external_certificates_offer_url = "admin/external-ca-model.self-signed-certificates-certificates" # Set to 'null' to communicate with Traefik via HTTP, i.e. no 'external_tls'
  external_ca_cert_offer_url      = "admin/external-ca-model.self-signed-certificates-send-ca-cert" # Required if 'external_certificates_offer_url' is set
}

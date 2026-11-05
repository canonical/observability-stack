mock_provider "juju" {}

variables {
  grafana                 = { storage_directives = { "foo" = "1G" } }
  loki                    = { storage_directives = { "foo" = "1G" } }
  opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  prometheus              = { storage_directives = { "foo" = "1G" } }
}

# --- external cert URLs both null: no validation error ---

run "external_cert_urls_both_null" {
  command = plan

  variables {
    external_certificates_offer_url = null
    external_ca_cert_offer_url      = null
  }
}

# --- external cert URLs both set: no validation error ---

run "external_cert_urls_both_set" {
  command = plan

  variables {
    external_certificates_offer_url = "admin/external-ca.tls-certificates"
    external_ca_cert_offer_url      = "admin/external-ca.send-ca-cert"
  }

  # otelcol pushes to Prometheus/Loki over ingress, so it must trust the external CA
  # that signed Traefik's server certificate.
  assert {
    condition     = contains(keys(juju_integration.external_ca_cert), "opentelemetry_collector")
    error_message = "Expected otelcol to receive the external CA cert when TLS is terminated at Traefik"
  }
}

# --- only external_certificates_offer_url set: validation error ---

run "external_certificates_offer_url_only_fails" {
  command = plan

  variables {
    external_certificates_offer_url = "admin/external-ca.tls-certificates"
    external_ca_cert_offer_url      = null
  }

  expect_failures = [var.external_certificates_offer_url]
}

# --- only external_ca_cert_offer_url set: validation error ---

run "external_ca_cert_offer_url_only_fails" {
  command = plan

  variables {
    external_certificates_offer_url = null
    external_ca_cert_offer_url      = "admin/external-ca.send-ca-cert"
  }

  expect_failures = [var.external_certificates_offer_url]
}

mock_provider "juju" {}

variables {
  model         = { uuid = "00000000-0000-0000-0000-000000000000" }
  s3_endpoint   = "foo"
  s3_access_key = "foo"
  s3_secret_key = "foo"
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

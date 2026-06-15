mock_provider "juju" {}

variables {
  model                = { uuid = "00000000-0000-0000-0000-000000000000" }
  s3_endpoint          = "foo"
  s3_access_key        = "foo"
  s3_secret_key        = "foo"
  postgresql_offer_url = "admin/postgresql.database"
}

# --- default: internal_tls enabled ---

run "internal_tls_enabled" {
  command = plan

  assert {
    condition     = length(module.ssc) == 1
    error_message = "Expected ssc module when internal_tls is enabled"
  }

  assert {
    condition     = length(juju_integration.internal_certificates) == 7
    error_message = "Unexpected internal_certificates integrations when internal_tls is enabled"
  }

  assert {
    condition     = length(juju_integration.traefik_receive_ca_certificate) == 1
    error_message = "Unexpected traefik_receive_ca_certificate integrations when internal_tls is enabled"
  }
}

# --- internal_tls disabled: no ingress via traefik ---

run "internal_tls_disabled" {
  command = plan

  variables { internal_tls = false }

  assert {
    condition     = length(module.ssc) == 0
    error_message = "Expected no self-signed-certificates module when internal_tls is disabled"
  }

  assert {
    condition     = length(juju_integration.internal_certificates) == 0
    error_message = "Unexpected internal_certificates integrations when internal_tls is disabled"
  }

  assert {
    condition     = length(juju_integration.traefik_receive_ca_certificate) == 0
    error_message = "Unexpected traefik_receive_ca_certificate integrations when internal_tls is disabled"
  }
}

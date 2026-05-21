mock_provider "juju" {}

variables { model_uuid = "00000000-0000-0000-0000-000000000000" }

# --- default: internal_tls enabled - ingress via traefik ---

run "internal_tls_enabled" {
  command = plan

  assert {
    condition     = length(module.ssc) == 1
    error_message = "Expected ssc module when internal_tls is enabled"
  }

  assert {
    condition     = length(module.traefik) == 1
    error_message = "Expected traefik module when internal_tls is enabled"
  }

  assert {
    condition     = length(juju_integration.ingress) == 4
    error_message = "Unexpected ingress integrations when internal_tls is enabled"
  }

  assert {
    condition     = length(juju_integration.grafana_ingress) == 1
    error_message = "Unexpected grafana_ingress integrations when internal_tls is enabled"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 2
    error_message = "Unexpected traefik_route integrations when internal_tls is enabled"
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
    condition     = length(module.traefik) == 0
    error_message = "Expected no traefik module when internal_tls is disabled"
  }

  assert {
    condition     = length(juju_integration.ingress) == 0
    error_message = "Unexpected ingress integrations when internal_tls is disabled"
  }

  assert {
    condition     = length(juju_integration.grafana_ingress) == 0
    error_message = "Unexpected grafana_ingress integrations when internal_tls is disabled"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 0
    error_message = "Unexpected traefik_route integrations when internal_tls is disabled"
  }
}

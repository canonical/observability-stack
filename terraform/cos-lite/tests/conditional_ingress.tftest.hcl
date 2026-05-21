mock_provider "juju" {}

variables { model_uuid = "00000000-0000-0000-0000-000000000000" }

# --- traefik: all ingress enabled by default ---

run "traefik_ingress_enabled" {
  command = plan

  assert {
    condition     = length(module.traefik) == 1
    error_message = "Expected a traefik module when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.ingress) == 2
    error_message = "Unexpected ingress integrations when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.ingress_per_unit) == 2
    error_message = "Unexpected ingress integrations when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.grafana_ingress) == 1
    error_message = "Unexpected grafana_ingress integrations when ingress is enabled"
  }
}

# --- traefik: all ingress disabled ---

run "traefik_ingress_disabled" {
  command = plan

  variables {
    ingress = {
      alertmanager            = false
      catalogue               = false
      grafana                 = false
      loki                    = false
      prometheus              = false
    }
  }

  assert {
    condition     = length(module.traefik) == 0
    error_message = "Expected no traefik module when ingress is disabled"
  }

  assert {
    condition     = length(juju_integration.ingress) == 0
    error_message = "Unexpected ingress integrations when ingress is disabled"
  }

  assert {
    condition     = length(juju_integration.ingress_per_unit) == 0
    error_message = "Unexpected ingress integrations when ingress is disabled"
  }

  assert {
    condition     = length(juju_integration.grafana_ingress) == 0
    error_message = "Unexpected grafana_ingress integrations when ingress is disabled"
  }
}

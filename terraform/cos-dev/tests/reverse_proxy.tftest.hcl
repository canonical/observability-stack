mock_provider "juju" {}

variables {
  model_uuid = "00000000-0000-0000-0000-000000000000"
}

# --- default: reverse proxy enabled - ingress via traefik ---

run "reverse_proxy_enabled" {
  command = plan

  assert {
    condition     = length(module.traefik) == 1
    error_message = "Expected traefik module when the reverse proxy is enabled"
  }

  assert {
    condition     = length(juju_integration.ingress) == 4
    error_message = "Expected 4 ingress integrations (alertmanager, catalogue, loki, mimir), got ${length(juju_integration.ingress)}"
  }

  # Grafana uses a separate count-based resource due to lifecycle replace_triggered_by
  assert {
    condition     = length(juju_integration.grafana_ingress) == 1
    error_message = "Expected 1 grafana_ingress integration, got ${length(juju_integration.grafana_ingress)}"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 2
    error_message = "Expected 2 traefik_route integrations (opentelemetry_collector, tempo), got ${length(juju_integration.traefik_route)}"
  }
}

# --- reverse proxy disabled: no ingress via traefik ---

run "reverse_proxy_disabled" {
  command = plan

  variables {
    mesh          = { enabled = false }
    reverse_proxy = { enabled = false }
  }

  assert {
    condition     = length(module.traefik) == 0
    error_message = "Expected no traefik module when the reverse proxy is disabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress) == 0
    error_message = "Expected 0 istio_ingress integrations when the reverse proxy is disabled, got ${length(juju_integration.istio_ingress)}"
  }

  assert {
    condition     = length(juju_integration.grafana_istio_ingress) == 0
    error_message = "Expected 0 grafana_istio_ingress integrations when the reverse proxy is disabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress_route) == 0
    error_message = "Expected 0 istio_ingress_route integrations when the reverse proxy is disabled"
  }
}

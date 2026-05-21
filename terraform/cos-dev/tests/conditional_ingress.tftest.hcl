mock_provider "juju" {}

variables { model_uuid = "00000000-0000-0000-0000-000000000000" }

# TODO: This feature also depends on the x2 Traefik story, maybe internal_tls is not the right name
# TODO: Do we need to remove offers / outputs TF conditionally?
# TODO: We need to keep the COS API the same across products: feature in COS, COS Lite, and COS Dev

# --- internal_tls: enabled - all ingress disabled ---

run "internal_tls_ingress_disabled" {
  command = plan

  variables {
    ingress = {
      alertmanager            = false
      catalogue               = false
      grafana                 = false
      loki                    = false
      mimir                   = false
      opentelemetry_collector = false
      tempo                   = false
    }
  }

  assert {
    condition     = length(juju_integration.ingress) == 0
    error_message = "Expected 0 ingress integrations, got ${length(juju_integration.ingress)}"
  }

  assert {
    condition     = length(juju_integration.grafana_ingress) == 0
    error_message = "Expected 0 grafana_ingress integrations, got ${length(juju_integration.grafana_ingress)}"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 0
    error_message = "Expected 0 traefik_route integrations, got ${length(juju_integration.traefik_route)}"
  }
}

# --- mesh: enabled - all ingress disabled ---

run "mesh_ingress_disabled" {
  command = plan

  variables {
    mesh_enabled = true
    internal_tls = false
    ingress = {
      alertmanager            = false
      catalogue               = false
      grafana                 = false
      loki                    = false
      mimir                   = false
      opentelemetry_collector = false
      tempo                   = false
    }
  }

  assert {
    condition     = length(juju_integration.istio_ingress) == 0
    error_message = "Expected 0 istio_ingress integrations, got ${length(juju_integration.istio_ingress)}"
  }

  assert {
    condition     = length(juju_integration.grafana_istio_ingress) == 0
    error_message = "Expected 0 grafana_istio_ingress integrations, got ${length(juju_integration.grafana_istio_ingress)}"
  }

  assert {
    condition     = length(juju_integration.istio_ingress_route) == 0
    error_message = "Expected 0 istio_ingress_route integrations, got ${length(juju_integration.istio_ingress_route)}"
  }
}

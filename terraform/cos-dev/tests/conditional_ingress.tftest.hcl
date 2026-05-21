mock_provider "juju" {}

variables { model_uuid = "00000000-0000-0000-0000-000000000000" }

# TODO: This feature also depends on the x2 Traefik story, maybe internal_tls is not the right name
# TODO: Do we need to remove offers / outputs TF conditionally?
# TODO: We need to keep the COS API the same across products: feature in COS, COS Lite, and COS Dev

# --- traefik: all ingress disabled ---

run "traefik_ingress_disabled" {
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
    condition     = length(module.traefik) == 0
    error_message = "Expected no traefik module when ingress is disabled"
  }

  assert {
    condition     = length(juju_integration.ingress) == 0
    error_message = "Unexpected ingress integrations when ingress is disabled"
  }

  assert {
    condition     = length(juju_integration.grafana_ingress) == 0
    error_message = "Unexpected grafana_ingress integrations when ingress is disabled"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 0
    error_message = "Unexpected traefik_route integrations when ingress is disabled"
  }
}

# --- istio: all ingress disabled ---

run "mesh_enabled_ingress_disabled" {
  command = plan

  variables {
    internal_tls = false
    mesh_enabled = true
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
    condition     = length(module.istio_ingress) == 0
    error_message = "Expected no istio_ingress module when ingress is disabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress) == 0
    error_message = "Unexpected istio_ingress integrations when ingress is disabled"
  }

  assert {
    condition     = length(juju_integration.grafana_istio_ingress) == 0
    error_message = "Unexpected grafana_istio_ingress integrations when ingress is disabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress_route) == 0
    error_message = "Unexpected istio_ingress_route integrations when ingress is disabled"
  }
}

# --- traefik: some ingress enabled ---

run "traefik_ingress_enabled" {
  command = plan

  variables {
    ingress = {
      alertmanager            = false
      catalogue               = true
      grafana                 = false
      loki                    = true
      mimir                   = false
      opentelemetry_collector = true
      tempo                   = false
    }
  }

  assert {
    condition     = length(module.traefik) == 1
    error_message = "Expected a traefik module when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.ingress) == 2
    error_message = "Unexpected ingress integrations when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.grafana_ingress) == 0
    error_message = "Unexpected grafana_ingress integrations when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 1
    error_message = "Unexpected traefik_route integrations when ingress is enabled"
  }
}

# --- istio: some ingress enabled ---

run "mesh_enabled_ingress_enabled" {
  command = plan

  variables {
    internal_tls = false
    mesh_enabled = true
    ingress = {
      alertmanager            = false
      catalogue               = true
      grafana                 = false
      loki                    = true
      mimir                   = false
      opentelemetry_collector = true
      tempo                   = false
    }
  }

  assert {
    condition     = length(module.istio_ingress) == 1
    error_message = "Expected an istio_ingress module when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress) == 2
    error_message = "Unexpected istio_ingress integrations when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.grafana_istio_ingress) == 0
    error_message = "Unexpected grafana_istio_ingress integrations when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress_route) == 1
    error_message = "Unexpected istio_ingress_route integrations when ingress is enabled"
  }
}

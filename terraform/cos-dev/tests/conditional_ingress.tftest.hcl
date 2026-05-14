mock_provider "juju" {}

variables {
  model_uuid = "00000000-0000-0000-0000-000000000000"
}

# --- Default: all ingress integrations enabled ---

run "default_ingress_all_enabled" {
  command = plan

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

# --- All ingress disabled ---

run "ingress_all_disabled" {
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

# --- Only grafana exposed ---

run "ingress_only_grafana" {
  command = plan

  variables {
    ingress = {
      alertmanager            = false
      catalogue               = false
      grafana                 = true
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
    condition     = length(juju_integration.grafana_ingress) == 1
    error_message = "Expected 1 grafana_ingress integration, got ${length(juju_integration.grafana_ingress)}"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 0
    error_message = "Expected 0 traefik_route integrations, got ${length(juju_integration.traefik_route)}"
  }
}

# --- Only tempo exposed (traefik_route) ---

run "ingress_only_tempo" {
  command = plan

  variables {
    ingress = {
      alertmanager            = false
      catalogue               = false
      grafana                 = false
      loki                    = false
      mimir                   = false
      opentelemetry_collector = false
      tempo                   = true
    }
  }

  assert {
    condition     = length(juju_integration.ingress) == 0
    error_message = "Expected 0 ingress integrations, got ${length(juju_integration.ingress)}"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 1
    error_message = "Expected 1 traefik_route integration (tempo), got ${length(juju_integration.traefik_route)}"
  }

  assert {
    condition     = contains(keys(juju_integration.traefik_route), "tempo")
    error_message = "Expected traefik_route to contain 'tempo' key"
  }
}

# --- Partial override: disable alertmanager and tempo ---

run "ingress_partial_override" {
  command = plan

  variables {
    ingress = {
      alertmanager = false
      tempo        = false
    }
  }

  assert {
    condition     = length(juju_integration.ingress) == 3
    error_message = "Expected 3 ingress integrations (catalogue, loki, mimir), got ${length(juju_integration.ingress)}"
  }

  assert {
    condition     = !contains(keys(juju_integration.ingress), "alertmanager")
    error_message = "Expected ingress to NOT contain 'alertmanager' key"
  }

  assert {
    condition     = length(juju_integration.grafana_ingress) == 1
    error_message = "Expected 1 grafana_ingress integration, got ${length(juju_integration.grafana_ingress)}"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 1
    error_message = "Expected 1 traefik_route integration (opentelemetry_collector), got ${length(juju_integration.traefik_route)}"
  }

  assert {
    condition     = contains(keys(juju_integration.traefik_route), "opentelemetry_collector")
    error_message = "Expected traefik_route to contain 'opentelemetry_collector' key"
  }
}

# --- mesh_enabled: all ingress via istio, none via traefik ---

run "mesh_ingress_all_enabled" {
  command = plan

  variables {
    mesh_enabled = true
    internal_tls = false
  }

  # Traefik ingress resources should be empty
  assert {
    condition     = length(juju_integration.ingress) == 0
    error_message = "Expected 0 traefik ingress integrations when mesh is enabled, got ${length(juju_integration.ingress)}"
  }

  assert {
    condition     = length(juju_integration.grafana_ingress) == 0
    error_message = "Expected 0 grafana_ingress integrations when mesh is enabled, got ${length(juju_integration.grafana_ingress)}"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 0
    error_message = "Expected 0 traefik_route integrations when mesh is enabled, got ${length(juju_integration.traefik_route)}"
  }

  # Istio ingress resources should be populated
  assert {
    condition     = length(juju_integration.istio_ingress) == 4
    error_message = "Expected 4 istio_ingress integrations (alertmanager, catalogue, loki, mimir), got ${length(juju_integration.istio_ingress)}"
  }

  assert {
    condition     = length(juju_integration.grafana_istio_ingress) == 1
    error_message = "Expected 1 grafana_istio_ingress integration, got ${length(juju_integration.grafana_istio_ingress)}"
  }

  assert {
    condition     = length(juju_integration.istio_ingress_route) == 2
    error_message = "Expected 2 istio_ingress_route integrations (opentelemetry_collector, tempo), got ${length(juju_integration.istio_ingress_route)}"
  }
}

# --- mesh_enabled with partial ingress override ---

run "mesh_ingress_partial" {
  command = plan

  variables {
    mesh_enabled = true
    internal_tls = false
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

  # Traefik resources should all be empty
  assert {
    condition     = length(juju_integration.ingress) == 0
    error_message = "Expected 0 traefik ingress integrations when mesh is enabled, got ${length(juju_integration.ingress)}"
  }

  assert {
    condition     = length(juju_integration.grafana_ingress) == 0
    error_message = "Expected 0 grafana_ingress integrations when mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 0
    error_message = "Expected 0 traefik_route integrations when mesh is enabled"
  }

  # Istio resources should respect the ingress toggles
  assert {
    condition     = length(juju_integration.istio_ingress) == 2
    error_message = "Expected 2 istio_ingress integrations (catalogue, loki), got ${length(juju_integration.istio_ingress)}"
  }

  assert {
    condition     = length(juju_integration.grafana_istio_ingress) == 0
    error_message = "Expected 0 grafana_istio_ingress integrations when grafana ingress is disabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress_route) == 1
    error_message = "Expected 1 istio_ingress_route integration (opentelemetry_collector), got ${length(juju_integration.istio_ingress_route)}"
  }
}

# --- mesh disabled (default): no istio ingress resources ---

run "no_mesh_no_istio_ingress" {
  command = plan

  assert {
    condition     = length(juju_integration.istio_ingress) == 0
    error_message = "Expected 0 istio_ingress integrations when mesh is disabled, got ${length(juju_integration.istio_ingress)}"
  }

  assert {
    condition     = length(juju_integration.grafana_istio_ingress) == 0
    error_message = "Expected 0 grafana_istio_ingress integrations when mesh is disabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress_route) == 0
    error_message = "Expected 0 istio_ingress_route integrations when mesh is disabled"
  }
}

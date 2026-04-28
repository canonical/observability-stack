mock_provider "juju" {}

variables {
  model_uuid    = "00000000-0000-0000-0000-000000000000"
  s3_endpoint   = "foo"
  s3_access_key = "foo"
  s3_secret_key = "foo"
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
    condition     = length(juju_integration.traefik_route) == 1
    error_message = "Expected 1 traefik_route integration (tempo), got ${length(juju_integration.traefik_route)}"
  }
}

# --- All ingress disabled ---

run "ingress_all_disabled" {
  command = plan

  variables {
    ingress = {
      alertmanager = false
      catalogue    = false
      grafana      = false
      loki         = false
      mimir        = false
      tempo        = false
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
      alertmanager = false
      catalogue    = false
      grafana      = true
      loki         = false
      mimir        = false
      tempo        = false
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
      alertmanager = false
      catalogue    = false
      grafana      = false
      loki         = false
      mimir        = false
      tempo        = true
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
    condition     = length(juju_integration.traefik_route) == 0
    error_message = "Expected 0 traefik_route integrations, got ${length(juju_integration.traefik_route)}"
  }
}

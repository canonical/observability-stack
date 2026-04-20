mock_provider "juju" {}

variables { model_uuid = "00000000-0000-0000-0000-000000000000" }

# --- Default: all ingress integrations enabled ---

run "default_ingress_all_enabled" {
  command = plan

  assert {
    condition     = length(juju_integration.ingress) == 3
    error_message = "Expected 3 ingress integrations (alertmanager, catalogue, grafana), got ${length(juju_integration.ingress)}"
  }

  assert {
    condition     = length(juju_integration.ingress_per_unit) == 2
    error_message = "Expected 2 ingress_per_unit integrations (loki, prometheus), got ${length(juju_integration.ingress_per_unit)}"
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
      prometheus   = false
    }
  }

  assert {
    condition     = length(juju_integration.ingress) == 0
    error_message = "Expected 0 ingress integrations, got ${length(juju_integration.ingress)}"
  }

  assert {
    condition     = length(juju_integration.ingress_per_unit) == 0
    error_message = "Expected 0 ingress_per_unit integrations, got ${length(juju_integration.ingress_per_unit)}"
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
      prometheus   = false
    }
  }

  assert {
    condition     = length(juju_integration.ingress) == 1
    error_message = "Expected 1 ingress integration (grafana only), got ${length(juju_integration.ingress)}"
  }

  assert {
    condition     = contains(keys(juju_integration.ingress), "grafana")
    error_message = "Expected ingress to contain 'grafana' key"
  }

  assert {
    condition     = length(juju_integration.ingress_per_unit) == 0
    error_message = "Expected 0 ingress_per_unit integrations, got ${length(juju_integration.ingress_per_unit)}"
  }
}

# --- Only per-unit apps exposed ---

run "ingress_only_per_unit" {
  command = plan

  variables {
    ingress = {
      alertmanager = false
      catalogue    = false
      grafana      = false
      loki         = true
      prometheus   = true
    }
  }

  assert {
    condition     = length(juju_integration.ingress) == 0
    error_message = "Expected 0 ingress integrations, got ${length(juju_integration.ingress)}"
  }

  assert {
    condition     = length(juju_integration.ingress_per_unit) == 2
    error_message = "Expected 2 ingress_per_unit integrations, got ${length(juju_integration.ingress_per_unit)}"
  }

  assert {
    condition     = contains(keys(juju_integration.ingress_per_unit), "loki")
    error_message = "Expected ingress_per_unit to contain 'loki' key"
  }

  assert {
    condition     = contains(keys(juju_integration.ingress_per_unit), "prometheus")
    error_message = "Expected ingress_per_unit to contain 'prometheus' key"
  }
}

# --- Partial override: disable only one from each group ---

run "ingress_partial_override" {
  command = plan

  variables {
    ingress = {
      alertmanager = false
      prometheus   = false
    }
  }

  assert {
    condition     = length(juju_integration.ingress) == 2
    error_message = "Expected 2 ingress integrations (catalogue, grafana), got ${length(juju_integration.ingress)}"
  }

  assert {
    condition     = !contains(keys(juju_integration.ingress), "alertmanager")
    error_message = "Expected ingress to NOT contain 'alertmanager' key"
  }

  assert {
    condition     = length(juju_integration.ingress_per_unit) == 1
    error_message = "Expected 1 ingress_per_unit integration (loki only), got ${length(juju_integration.ingress_per_unit)}"
  }

  assert {
    condition     = !contains(keys(juju_integration.ingress_per_unit), "prometheus")
    error_message = "Expected ingress_per_unit to NOT contain 'prometheus' key"
  }
}

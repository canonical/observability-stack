mock_provider "juju" {}

variables {
  model_uuid = "00000000-0000-0000-0000-000000000000"
}

# --- mesh and reverse_proxy enabled: validation error ---

run "mesh_and_reverse_proxy_enabled_fails" {
  command = plan

  variables {
    mesh          = { enabled = false }
    reverse_proxy = { enabled = true }
  }

  expect_failures = [var.mesh.enabled]
}

# --- mesh and reverse_proxy disabled: no validation error ---

run "mesh_and_reverse_proxy_disabled" {
  command = plan

  variables {
    mesh          = { enabled = false }
    reverse_proxy = { enabled = false }
  }
}

# --- default: mesh disabled - no ingress via istio ---

run "mesh_disabled" {
  command = plan

  assert {
    condition     = length(module.istio-beacon) == 0
    error_message = "Expected no istio-beacon module when the mesh is disabled"
  }

  assert {
    condition     = length(module.istio-ingress) == 0
    error_message = "Expected no istio-ingress module when the mesh is disabled"
  }

  assert {
    condition     = length(juju_integration.istio_beacon) == 0
    error_message = "Expected no istio_beacon integrations when the mesh is disabled"
  }

  assert {
    condition     = length(juju_integration.grafana_istio_ingress) == 0
    error_message = "Expected no grafana_istio_beacon integrations when the mesh is disabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress_route) == 0
    error_message = "Expected no istio_ingress_route integrations when the mesh is disabled"
  }
}

# --- mesh enabled: ingress via istio ---

run "mesh_enabled" {
  command = plan

  variables {
    mesh          = { enabled = true }
    reverse_proxy = { enabled = false }
  }

  assert {
    condition     = length(module.istio-beacon) == 1
    error_message = "Expected istio-beacon module when the mesh is enabled"
  }

  assert {
    condition     = length(module.istio-ingress) == 1
    error_message = "Expected istio-ingress module when the mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress) == 4
    error_message = "Expected 4 istio_ingress integrations (alertmanager, catalogue, loki, mimir), got ${length(juju_integration.istio_ingress)}"
  }

  # Grafana uses a separate count-based resource due to lifecycle replace_triggered_by
  assert {
    condition     = length(juju_integration.grafana_istio_ingress) == 1
    error_message = "Expected 1 grafana_istio_ingress integration, got ${length(juju_integration.grafana_istio_ingress)}"
  }

  assert {
    condition     = length(juju_integration.istio_ingress_route) == 2
    error_message = "Expected 2 istio_ingress_route integrations (opentelemetry_collector, tempo), got ${length(juju_integration.istio_ingress_route)}"
  }
}

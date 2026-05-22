mock_provider "juju" {}

variables { model_uuid = "00000000-0000-0000-0000-000000000000" }

# --- mesh and internal_tls disabled: no validation error ---

run "mesh_and_internal_tls_disabled" {
  command = plan

  variables {
    service_mesh = false
    internal_tls = false
  }
}

# --- mesh and internal_tls enabled: validation error ---

run "mesh_and_internal_tls_enabled_fails" {
  command = plan

  variables {
    service_mesh = true
    internal_tls = true
  }

  expect_failures = [var.service_mesh]
}

# --- default: mesh disabled - no ingress via istio ---

run "mesh_disabled" {
  command = plan

  assert {
    condition     = length(module.istio_beacon) == 0
    error_message = "Expected no istio_beacon module when the mesh is disabled"
  }

  assert {
    condition     = length(module.istio_ingress) == 0
    error_message = "Expected no istio_ingress module when the mesh is disabled"
  }

  assert {
    condition     = length(juju_integration.istio_beacon) == 0
    error_message = "Expected no istio_beacon integrations when the mesh is disabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress) == 0
    error_message = "Expected no istio_ingress integrations when the mesh is disabled"
  }

  assert {
    condition     = length(juju_integration.grafana_istio_ingress) == 0
    error_message = "Expected no grafana_istio_ingress integrations when the mesh is disabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress_route) == 0
    error_message = "Expected no istio_ingress_route integrations when the mesh is disabled"
  }
}

# --- mesh enabled: ingress via istio ---

run "service_mesh" {
  command = plan

  variables {
    service_mesh = true
    internal_tls = false
  }

  assert {
    condition     = length(module.istio_beacon) == 1
    error_message = "Expected istio_beacon module when the mesh is enabled"
  }

  assert {
    condition     = length(module.istio_ingress) == 1
    error_message = "Expected istio_ingress module when the mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.istio_beacon) == 7
    error_message = "Unexpected istio_beacon integrations when the mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress) == 4
    error_message = "Unexpected istio_ingress integrations when the mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.grafana_istio_ingress) == 1
    error_message = "Unexpected grafana_istio_ingress integrations when the mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.istio_ingress_route) == 2
    error_message = "Unexpected istio_ingress_route integrations when the mesh is enabled"

  }
}

mock_provider "juju" {}

variables {
  model_uuid = "00000000-0000-0000-0000-000000000000"
}

# --- mesh_enabled=false (default): no istio modules or integrations deployed ---

run "mesh_disabled_by_default" {
  command = plan

  assert {
    condition     = length(module.istio-beacon) == 0
    error_message = "Expected no istio-beacon module when mesh is disabled"
  }

  assert {
    condition     = length(module.istio-ingress) == 0
    error_message = "Expected no istio-ingress module when mesh is disabled"
  }

  assert {
    condition     = length(juju_integration.istio_beacon) == 0
    error_message = "Expected no istio_beacon integrations when mesh is disabled"
  }
}

# --- mesh_enabled=true with internal_tls=false: istio modules and integrations deployed ---

run "mesh_enabled_without_tls" {
  command = plan

  variables {
    mesh_enabled = true
    internal_tls = false
  }

  assert {
    condition     = length(module.istio-beacon) == 1
    error_message = "Expected istio-beacon module to be deployed when mesh is enabled"
  }

  assert {
    condition     = length(module.istio-ingress) == 1
    error_message = "Expected istio-ingress module to be deployed when mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.istio_beacon) == 7
    error_message = "Expected 7 istio_beacon integrations (one per component) when mesh is enabled"
  }
}

# --- mesh_enabled=true with internal_tls=true (default): validation error ---

run "mesh_enabled_with_internal_tls_fails" {
  command = plan

  variables {
    mesh_enabled = true
    internal_tls = true
  }

  expect_failures = [var.mesh_enabled]
}

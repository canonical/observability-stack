mock_provider "juju" {}

variables {
  s3_endpoint             = "foo"
  s3_access_key           = "foo"
  s3_secret_key           = "foo"
  postgresql_offer_url    = "admin/postgresql.database"
  grafana                 = { storage_directives = { "foo" = "1G" } }
  loki_worker             = { write_storage_directives = { "foo" = "1G" } }
  mimir_worker            = { write_storage_directives = { "foo" = "1G" }, backend_storage_directives = { "foo" = "1G" } }
  tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
  opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
}

# --- mesh and internal_tls enabled: validation error ---

run "mesh_and_internal_tls_enabled_fails" {
  command = plan

  variables {
    mesh_enabled = true
    internal_tls = true
  }

  expect_failures = [var.mesh_enabled]
}

# --- mesh and internal_tls disabled: no validation error ---

run "mesh_and_internal_tls_disabled" {
  command = plan

  variables {
    mesh_enabled = false
    internal_tls = false
  }
}

# --- default: mesh disabled - no istio, ingress via traefik ---

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
    condition     = length(module.traefik) == 1
    error_message = "Expected a traefik module when the mesh is disabled"
  }
}

# --- mesh enabled: istio replaces traefik and ssc ---

run "mesh_enabled" {
  command = plan

  variables {
    mesh_enabled = true
    internal_tls = false
  }

  assert {
    condition     = length(module.istio_beacon) == 1
    error_message = "Expected an istio_beacon module when the mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.istio_beacon) == 7
    error_message = "Unexpected istio_beacon integrations when the mesh is enabled"
  }

  assert {
    condition     = length(module.traefik) == 0
    error_message = "Expected no traefik module when the mesh is enabled"
  }

  assert {
    condition     = length(module.ssc) == 0
    error_message = "Expected no self-signed-certificates module when the mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.ingress) == 0
    error_message = "Unexpected traefik ingress integrations when the mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.grafana_ingress) == 0
    error_message = "Unexpected traefik grafana_ingress integrations when the mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 0
    error_message = "Unexpected traefik_route integrations when the mesh is enabled"
  }
}

# --- mesh enabled with an external CA: istio-ingress terminates TLS ---

run "mesh_enabled_external_tls" {
  command = plan

  variables {
    mesh_enabled                    = true
    internal_tls                    = false
    external_certificates_offer_url = "admin/external-ca.certificates"
    external_ca_cert_offer_url      = "admin/external-ca.send-ca-cert"
  }

  assert {
    condition     = length(juju_integration.external_istio_ingress_certificates) == 1
    error_message = "Expected istio-ingress to be integrated with the external CA when the mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.external_traefik_certificates) == 0
    error_message = "Unexpected traefik external certificates integrations when the mesh is enabled"
  }

  assert {
    condition     = length(juju_integration.external_ca_cert) == 2
    error_message = "Expected grafana and otelcol to trust the external CA when the mesh is enabled"
  }
}

mock_provider "juju" {}

variables {
  s3_endpoint             = "foo"
  s3_access_key           = "foo"
  s3_secret_key           = "foo"
  postgresql_offer_url    = "admin/postgresql.database"
  alertmanager            = { storage_directives = { "foo" = "1G" } }
  grafana                 = { storage_directives = { "foo" = "1G" } }
  loki_worker             = { write_storage_directives = { "foo" = "1G" } }
  mimir_worker            = { write_storage_directives = { "foo" = "1G" }, backend_storage_directives = { "foo" = "1G" } }
  tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
  opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
}

# --- traefik: tempo and otelcol ingress enabled raises validation errror ---

run "traefik_ingress_validates_conflicting_ingress" {
  command = plan

  variables {
    ingress = {
      opentelemetry_collector = true
      tempo                   = true
    }
  }

  # https://github.com/canonical/observability-stack/issues/382
  expect_failures = [var.ingress]
}

# --- traefik: all ingress enabled by default ---

run "traefik_ingress_enabled" {
  command = plan

  assert {
    condition     = length(module.traefik) == 1
    error_message = "Expected a traefik module when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.ingress) == 4
    error_message = "Unexpected ingress integrations when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.grafana_ingress) == 1
    error_message = "Unexpected grafana_ingress integrations when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 1
    error_message = "Unexpected traefik_route integrations when ingress is enabled"
  }
}

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

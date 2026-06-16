mock_provider "juju" {}

variables {
  s3_endpoint             = "foo"
  s3_access_key           = "foo"
  s3_secret_key           = "foo"
  alertmanager            = { storage_directives = { "foo" = "1G" } }
  grafana                 = { storage_directives = { "foo" = "1G" } }
  loki_worker             = { write_storage_directives = { "foo" = "1G" } }
  mimir_worker            = { write_storage_directives = { "foo" = "1G" }, backend_storage_directives = { "foo" = "1G" } }
  tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
  opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
}

# --- grafana: scale > 1 requires database offer ---

run "default_grafana_requires_database_offer" {
  command = plan

  expect_failures = [var.postgresql_offer_url]
}

# --- grafana: scale > 1 with database offer integration ---

run "grafana_conditionally_integrated_to_database_offer" {
  command = plan

  variables { postgresql_offer_url = "admin/postgresql.database" }

  assert {
    condition     = length(juju_integration.grafana_database) == 1
    error_message = "Expected a grafana_database integration when an offer URL is supplied"
  }
}

# --- grafana: scale 1 with database offer integration ---

run "grafana_scale_1_integrated_to_database_offer" {
  command = plan

  variables {
    grafana              = { units = 1, storage_directives = { "foo" = "1G" } }
    postgresql_offer_url = "admin/postgresql.database"
  }

  assert {
    condition     = length(juju_integration.grafana_database) == 1
    error_message = "Expected a grafana_database integration when an offer URL is supplied at scale 1"
  }
}

# --- grafana: scale 1 does not require database offer ---

run "grafana_scale_1_no_database_offer" {
  command = plan

  variables { grafana = { units = 1, storage_directives = { "foo" = "1G" } } }

  assert {
    condition     = length(juju_integration.grafana_database) == 0
    error_message = "Unexpected grafana_database integrations when no offer URL is supplied"
  }
}

mock_provider "juju" {}

variables {
  grafana    = { storage_directives = { "foo" = "1G" } }
  loki       = { storage_directives = { "foo" = "1G" } }
  prometheus = { storage_directives = { "foo" = "1G" } }
}

# --- grafana: default scale (1 unit) does not require a database offer ---

run "default_grafana_no_database_offer" {
  command = plan

  assert {
    condition     = length(juju_integration.grafana_database) == 0
    error_message = "Unexpected grafana_database integrations when no offer URL is supplied at the default scale"
  }
}

# --- grafana: scale > 1 requires a database offer ---

run "grafana_scale_gt_1_requires_database_offer" {
  command = plan

  variables {
    grafana = { units = 2, storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [var.postgresql_offer_url]
}

# --- grafana: scale > 1 with database offer integration ---

run "grafana_scale_gt_1_integrated_to_database_offer" {
  command = plan

  variables {
    grafana              = { units = 2, storage_directives = { "foo" = "1G" } }
    postgresql_offer_url = "admin/postgresql.database"
  }

  assert {
    condition     = length(juju_integration.grafana_database) == 1
    error_message = "Expected a grafana_database integration when an offer URL is supplied at scale > 1"
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

# --- grafana: scale 1 does not require a database offer ---

run "grafana_scale_1_no_database_offer" {
  command = plan

  variables {
    grafana = { units = 1, storage_directives = { "foo" = "1G" } }
  }

  assert {
    condition     = length(juju_integration.grafana_database) == 0
    error_message = "Unexpected grafana_database integrations when no offer URL is supplied"
  }
}

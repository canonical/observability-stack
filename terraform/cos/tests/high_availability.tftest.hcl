mock_provider "juju" {}

variables {
  s3_endpoint             = "foo"
  s3_access_key           = "foo"
  s3_secret_key           = "foo"
  postgresql_offer_url    = "admin/postgresql.database"
  loki_worker             = { write_storage_directives = { "foo" = "1G" } }
  opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  mimir_worker            = { write_storage_directives = { "foo" = "1G" }, backend_storage_directives = { "foo" = "1G" } }
  tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
}

# --- HA components must not default to a single unit ---

run "ha_components_default_to_more_than_one_unit" {
  command = plan

  assert {
    condition     = module.traefik[0].application.units > 1
    error_message = "Expected Traefik to default to more than one unit for high availability"
  }

  assert {
    condition     = var.opentelemetry_collector.units > 1
    error_message = "Expected the OpenTelemetry Collector to default to more than one unit"
  }

  assert {
    condition     = var.alertmanager.units > 1
    error_message = "Expected Alertmanager to default to more than one unit"
  }

  assert {
    condition     = var.grafana.units > 1
    error_message = "Expected Grafana to default to more than one unit"
  }

  assert {
    condition     = var.loki_coordinator.units > 1
    error_message = "Expected the Loki coordinator to default to more than one unit"
  }

  assert {
    condition     = alltrue([var.loki_worker.backend_units > 1, var.loki_worker.read_units > 1, var.loki_worker.write_units > 1])
    error_message = "Expected all Loki workers to default to more than one unit"
  }

  assert {
    condition     = var.mimir_coordinator.units > 1
    error_message = "Expected the Mimir coordinator to default to more than one unit"
  }

  assert {
    condition     = alltrue([var.mimir_worker.backend_units > 1, var.mimir_worker.read_units > 1, var.mimir_worker.write_units > 1])
    error_message = "Expected all Mimir workers to default to more than one unit"
  }

  assert {
    condition     = var.tempo_coordinator.units > 1
    error_message = "Expected the Tempo coordinator to default to more than one unit"
  }

  assert {
    condition = alltrue([
      var.tempo_worker.compactor_units > 1,
      var.tempo_worker.distributor_units > 1,
      var.tempo_worker.ingester_units > 1,
      var.tempo_worker.metrics_generator_units > 1,
      var.tempo_worker.querier_units > 1,
      var.tempo_worker.query_frontend_units > 1,
    ])
    error_message = "Expected all Tempo workers to default to more than one unit"
  }
}

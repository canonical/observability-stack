mock_provider "juju" {}

variables {
  s3_endpoint          = "foo"
  s3_access_key        = "foo"
  s3_secret_key        = "foo"
  postgresql_offer_url = "admin/postgresql.database"
}

run "warns_when_alertmanager_storage_directives_unset" {
  command = plan

  variables {
    grafana                 = { storage_directives = { "foo" = "1G" } }
    loki_worker             = { write_storage_directives = { "foo" = "1G" } }
    mimir_worker            = { write_storage_directives = { "foo" = "1G" }, backend_storage_directives = { "foo" = "1G" } }
    tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
    opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.alertmanager_storage_directives,
  ]
}

run "warns_when_grafana_storage_directives_unset" {
  command = plan

  variables {
    alertmanager            = { storage_directives = { "foo" = "1G" } }
    loki_worker             = { write_storage_directives = { "foo" = "1G" } }
    mimir_worker            = { write_storage_directives = { "foo" = "1G" }, backend_storage_directives = { "foo" = "1G" } }
    tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
    opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.grafana_storage_directives,
  ]
}

run "warns_when_loki_worker_storage_directives_unset" {
  command = plan

  variables {
    alertmanager            = { storage_directives = { "foo" = "1G" } }
    grafana                 = { storage_directives = { "foo" = "1G" } }
    mimir_worker            = { write_storage_directives = { "foo" = "1G" }, backend_storage_directives = { "foo" = "1G" } }
    tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
    opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.loki_worker_storage_directives,
  ]
}

run "warns_when_mimir_worker_storage_directives_unset" {
  command = plan

  variables {
    alertmanager            = { storage_directives = { "foo" = "1G" } }
    grafana                 = { storage_directives = { "foo" = "1G" } }
    loki_worker             = { write_storage_directives = { "foo" = "1G" } }
    mimir_worker            = { backend_storage_directives = { "foo" = "1G" } }
    tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
    opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.mimir_worker_storage_directives,
  ]
}

run "warns_when_mimir_worker_backend_storage_directives_unset" {
  command = plan

  variables {
    alertmanager            = { storage_directives = { "foo" = "1G" } }
    grafana                 = { storage_directives = { "foo" = "1G" } }
    loki_worker             = { write_storage_directives = { "foo" = "1G" } }
    mimir_worker            = { write_storage_directives = { "foo" = "1G" } }
    tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
    opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.mimir_worker_backend_storage_directives,
  ]
}

run "warns_when_tempo_worker_storage_directives_unset" {
  command = plan

  variables {
    alertmanager            = { storage_directives = { "foo" = "1G" } }
    grafana                 = { storage_directives = { "foo" = "1G" } }
    loki_worker             = { write_storage_directives = { "foo" = "1G" } }
    mimir_worker            = { write_storage_directives = { "foo" = "1G" }, backend_storage_directives = { "foo" = "1G" } }
    opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.tempo_worker_storage_directives,
  ]
}

run "warns_when_opentelemetry_collector_storage_directives_unset" {
  command = plan

  variables {
    alertmanager = { storage_directives = { "foo" = "1G" } }
    grafana      = { storage_directives = { "foo" = "1G" } }
    loki_worker  = { write_storage_directives = { "foo" = "1G" } }
    mimir_worker = { write_storage_directives = { "foo" = "1G" }, backend_storage_directives = { "foo" = "1G" } }
    tempo_worker = { ingester_worker_storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.opentelemetry_collector_storage_directives,
  ]
}

run "no_warning_when_all_storage_directives_set" {
  command = plan

  variables {
    alertmanager            = { storage_directives = { "foo" = "1G" } }
    grafana                 = { storage_directives = { "foo" = "1G" } }
    loki_worker             = { write_storage_directives = { "foo" = "1G" } }
    mimir_worker            = { write_storage_directives = { "foo" = "1G" }, backend_storage_directives = { "foo" = "1G" } }
    tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
    opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  }
}

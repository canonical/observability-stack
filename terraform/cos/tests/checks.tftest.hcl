mock_provider "juju" {}

variables {
  model         = { uuid = "00000000-0000-0000-0000-000000000000" }
  s3_endpoint   = "foo"
  s3_access_key = "foo"
  s3_secret_key = "foo"
}

# Each "only X unset" run sets storage for the other four components and leaves
# the target unset. This proves each check is wired to its own variable: a
# copy-paste bug (e.g. the mimir check reading var.loki_worker) would either
# fail to fire here or fire unexpectedly in a sibling run, failing the test.

run "warns_when_alertmanager_storage_directives_unset" {
  command = plan

  variables {
    loki_worker             = { write_storage_directives = { "foo" = "1G" } }
    mimir_worker            = { write_storage_directives = { "foo" = "1G" } }
    tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
    opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.alertmanager_storage_directives,
  ]
}

run "warns_when_loki_worker_storage_directives_unset" {
  command = plan

  variables {
    alertmanager            = { storage_directives = { "foo" = "1G" } }
    mimir_worker            = { write_storage_directives = { "foo" = "1G" } }
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
    loki_worker             = { write_storage_directives = { "foo" = "1G" } }
    tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
    opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.mimir_worker_storage_directives,
  ]
}

run "warns_when_tempo_worker_storage_directives_unset" {
  command = plan

  variables {
    alertmanager            = { storage_directives = { "foo" = "1G" } }
    loki_worker             = { write_storage_directives = { "foo" = "1G" } }
    mimir_worker            = { write_storage_directives = { "foo" = "1G" } }
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
    loki_worker  = { write_storage_directives = { "foo" = "1G" } }
    mimir_worker = { write_storage_directives = { "foo" = "1G" } }
    tempo_worker = { ingester_worker_storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.opentelemetry_collector_storage_directives,
  ]
}

# All five set: no check should warn. An unexpected check warning fails a run
# in `terraform test`, so this run has real teeth and proves suppression.
run "no_warning_when_all_storage_directives_set" {
  command = plan

  variables {
    alertmanager            = { storage_directives = { "foo" = "1G" } }
    loki_worker             = { write_storage_directives = { "foo" = "1G" } }
    mimir_worker            = { write_storage_directives = { "foo" = "1G" } }
    tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
    opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  }
}

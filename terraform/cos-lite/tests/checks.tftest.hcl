mock_provider "juju" {}

run "warns_when_alertmanager_storage_directives_unset" {
  command = plan

  variables {
    loki       = { storage_directives = { "loki-chunks" = "100G" } }
    prometheus = { storage_directives = { "database" = "100G" } }
  }

  expect_failures = [
    check.alertmanager_storage_directives,
  ]
}

run "warns_when_loki_storage_directives_unset" {
  command = plan

  variables {
    alertmanager = { storage_directives = { "data" = "10G" } }
    prometheus   = { storage_directives = { "database" = "100G" } }
  }

  expect_failures = [
    check.loki_storage_directives,
  ]
}

run "warns_when_prometheus_storage_directives_unset" {
  command = plan

  variables {
    alertmanager = { storage_directives = { "data" = "10G" } }
    loki         = { storage_directives = { "loki-chunks" = "100G" } }
  }

  expect_failures = [
    check.prometheus_storage_directives,
  ]
}

run "no_warning_when_all_storage_directives_set" {
  command = plan

  variables {
    alertmanager = { storage_directives = { "data" = "10G" } }
    loki         = { storage_directives = { "loki-chunks" = "100G" } }
    prometheus   = { storage_directives = { "database" = "100G" } }
  }
}

mock_provider "juju" {}

run "warns_when_alertmanager_storage_directives_unset" {
  command = plan

  variables {
    grafana    = { storage_directives = { "foo" = "1G" } }
    loki       = { storage_directives = { "foo" = "1G" } }
    prometheus = { storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.alertmanager_storage_directives,
  ]
}

run "warns_when_grafana_storage_directives_unset" {
  command = plan

  variables {
    alertmanager = { storage_directives = { "foo" = "1G" } }
    loki         = { storage_directives = { "foo" = "1G" } }
    prometheus   = { storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.grafana_storage_directives,
  ]
}

run "warns_when_loki_storage_directives_unset" {
  command = plan

  variables {
    alertmanager = { storage_directives = { "foo" = "1G" } }
    grafana      = { storage_directives = { "foo" = "1G" } }
    prometheus   = { storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.loki_storage_directives,
  ]
}

run "warns_when_prometheus_storage_directives_unset" {
  command = plan

  variables {
    alertmanager = { storage_directives = { "foo" = "1G" } }
    grafana      = { storage_directives = { "foo" = "1G" } }
    loki         = { storage_directives = { "foo" = "1G" } }
  }

  expect_failures = [
    check.prometheus_storage_directives,
  ]
}

run "no_warning_when_all_storage_directives_set" {
  command = plan

  variables {
    alertmanager = { storage_directives = { "foo" = "1G" } }
    grafana      = { storage_directives = { "foo" = "1G" } }
    loki         = { storage_directives = { "foo" = "1G" } }
    prometheus   = { storage_directives = { "foo" = "1G" } }
  }
}

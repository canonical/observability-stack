mock_provider "juju" {}

variables {
  s3_endpoint             = "foo"
  s3_access_key           = "foo"
  s3_secret_key           = "foo"
  grafana                 = { storage_directives = { "foo" = "1G" } }
  loki_worker             = { write_storage_directives = { "foo" = "1G" } }
  mimir_worker            = { write_storage_directives = { "foo" = "1G" }, backend_storage_directives = { "foo" = "1G" } }
  tempo_worker            = { ingester_worker_storage_directives = { "foo" = "1G" } }
  opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
}

# --- units: scales every HA component to a single unit ---
# Grafana at 1 unit also drops the PostgreSQL-offer requirement, which the base
# variables intentionally leave unset.

run "units_preset_scales_down" {
  command = plan

  variables {
    preset = "units"
  }

  assert {
    condition     = local.values.alertmanager.units == 1
    error_message = "Expected alertmanager units 1, got ${local.values.alertmanager.units}"
  }

  assert {
    condition     = local.values.grafana.units == 1
    error_message = "Expected grafana units 1, got ${local.values.grafana.units}"
  }

  assert {
    condition     = local.values.loki_worker.backend_units == 1 && local.values.loki_worker.read_units == 1 && local.values.loki_worker.write_units == 1
    error_message = "Expected all loki worker roles at 1 unit"
  }

  assert {
    condition     = local.values.mimir_worker.backend_units == 1 && local.values.mimir_worker.read_units == 1 && local.values.mimir_worker.write_units == 1
    error_message = "Expected all mimir worker roles at 1 unit"
  }

  assert {
    condition     = local.values.tempo_worker.compactor_units == 1 && local.values.tempo_worker.query_frontend_units == 1
    error_message = "Expected tempo worker roles at 1 unit"
  }
}

# --- no-ingress: disables Traefik and every ingress integration ---

run "no_ingress_preset_disables_traefik" {
  command = plan

  variables {
    preset               = "no-ingress"
    postgresql_offer_url = "admin/postgresql.database"
  }

  assert {
    condition     = local.values.ingress.grafana == false && local.values.ingress.opentelemetry_collector == false
    error_message = "Expected ingress to be disabled by the preset"
  }

  assert {
    condition     = length(module.traefik) == 0
    error_message = "Expected no traefik module when the no-ingress preset is applied"
  }

  assert {
    condition     = length(juju_integration.ingress) == 0
    error_message = "Expected no ingress integrations when the no-ingress preset is applied"
  }
}

# --- the preset only overrides the fields it declares; explicit args survive ---

run "preset_merges_with_explicit_values" {
  command = plan

  variables {
    preset       = "units"
    alertmanager = { app_name = "custom-alertmanager" }
  }

  assert {
    condition     = local.values.alertmanager.units == 1
    error_message = "Expected units to come from the preset, got ${local.values.alertmanager.units}"
  }

  assert {
    condition     = local.values.alertmanager.app_name == "custom-alertmanager"
    error_message = "Expected app_name to survive the preset merge, got ${local.values.alertmanager.app_name}"
  }
}

# --- no preset: module defaults are unchanged ---

run "without_preset_defaults_are_unchanged" {
  command = plan

  variables {
    postgresql_offer_url = "admin/postgresql.database"
  }

  assert {
    condition     = local.values.alertmanager.units == 3
    error_message = "Expected the default alertmanager units 3, got ${local.values.alertmanager.units}"
  }

  assert {
    condition     = local.values.ingress.alertmanager == true
    error_message = "Expected ingress to remain enabled by default"
  }
}

# --- an unknown preset is rejected with the list of available names ---

run "unknown_preset_is_rejected" {
  command = plan

  variables {
    preset = "does-not-exist"
  }

  expect_failures = [var.preset]
}

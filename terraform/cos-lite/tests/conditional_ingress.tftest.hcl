mock_provider "juju" {}

variables {
  grafana                 = { storage_directives = { "foo" = "1G" } }
  loki                    = { storage_directives = { "foo" = "1G" } }
  opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  prometheus              = { storage_directives = { "foo" = "1G" } }
}

# --- traefik: all ingress enabled by default ---

run "traefik_ingress_enabled" {
  command = plan

  assert {
    condition     = length(module.traefik) == 1
    error_message = "Expected a traefik module when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.ingress) == 2
    error_message = "Unexpected ingress integrations when ingress is enabled"
  }

  assert {
    condition     = length(juju_integration.ingress_per_unit) == 2
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

# --- traefik: otelcol is ingressed via traefik_route ---
# otelcol is the ingestion entrypoint for telemetry pushed in from other models, so it
# takes the ingress by default and needs traefik_route rather than ingress(-per-unit).

run "traefik_route_ingresses_otelcol" {
  command = plan

  assert {
    condition     = contains(keys(juju_integration.traefik_route), "opentelemetry_collector")
    error_message = "Expected opentelemetry_collector to be ingressed by default"
  }

  assert {
    condition     = !contains(keys(juju_integration.ingress), "opentelemetry_collector")
    error_message = "Expected opentelemetry_collector to NOT use the ingress endpoint"
  }

  assert {
    condition     = !contains(keys(juju_integration.ingress_per_unit), "opentelemetry_collector")
    error_message = "Expected opentelemetry_collector to NOT use the ingress_per_unit endpoint"
  }
}

# --- traefik: otelcol ingress can be disabled on its own ---

run "traefik_route_otelcol_ingress_disabled" {
  command = plan

  variables {
    ingress = {
      opentelemetry_collector = false
    }
  }

  assert {
    condition     = length(module.traefik) == 1
    error_message = "Expected a traefik module when other components are still ingressed"
  }

  assert {
    condition     = length(juju_integration.traefik_route) == 0
    error_message = "Unexpected traefik_route integrations when otelcol ingress is disabled"
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
      opentelemetry_collector = false
      prometheus              = false
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
    condition     = length(juju_integration.ingress_per_unit) == 0
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

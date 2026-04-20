mock_provider "juju" {}

variables { model_uuid = "00000000-0000-0000-0000-000000000000" }

# --- User revision pin is respected and not overridden by juju_charm datasource ---

run "user_revision_pin_is_respected" {
  command = plan

  variables {
    alertmanager = { revision = 1 }
    catalogue = { revision = 1 }
    grafana = { revision = 1 }
    loki_coordinator = { revision = 1 }
    loki_worker = { revision = 1 }
    mimir_coordinator = { revision = 1 }
    mimir_worker = { revision = 1 }
    opentelemetry_collector = { revision = 1 }
    ssc = { revision = 1 }
    s3_integrator = { revision = 1 }
    tempo_coordinator = { revision = 1 }
    tempo_worker = { revision = 1 }
    traefik = { revision = 1 }
  }

  assert {
    condition     = local.revisions.alertmanager == 1
    error_message = "Expected alertmanager revision 1, got ${local.revisions.alertmanager}"
  }

  assert {
    condition     = local.revisions.catalogue == 1
    error_message = "Expected catalogue revision 1, got ${local.revisions.catalogue}"
  }

  assert {
    condition     = local.revisions.grafana == 1
    error_message = "Expected grafana revision 1, got ${local.revisions.grafana}"
  }

  assert {
    condition     = local.revisions.loki_coordinator == 1
    error_message = "Expected loki_coordinator revision 1, got ${local.revisions.loki_coordinator}"
  }

  assert {
    condition     = local.revisions.loki_worker == 1
    error_message = "Expected loki_worker revision 1, got ${local.revisions.loki_worker}"
  }

  assert {
    condition     = local.revisions.mimir_coordinator == 1
    error_message = "Expected mimir_coordinator revision 1, got ${local.revisions.mimir_coordinator}"
  }

  assert {
    condition     = local.revisions.mimir_worker == 1
    error_message = "Expected mimir_worker revision 1, got ${local.revisions.mimir_worker}"
  }

  assert {
    condition     = local.revisions.otelcol == 1
    error_message = "Expected otelcol revision 1, got ${local.revisions.otelcol}"
  }

  assert {
    condition     = local.revisions.ssc == 1
    error_message = "Expected ssc revision 1, got ${local.revisions.ssc}"
  }

  assert {
    condition     = local.revisions.s3_integrator == 1
    error_message = "Expected s3_integrator revision 1, got ${local.revisions.s3_integrator}"
  }

  assert {
    condition     = local.revisions.tempo_coordinator == 1
    error_message = "Expected tempo_coordinator revision 1, got ${local.revisions.tempo_coordinator}"
  }

  assert {
    condition     = local.revisions.tempo_worker == 1
    error_message = "Expected tempo_worker revision 1, got ${local.revisions.tempo_worker}"
  }

  assert {
    condition     = local.revisions.traefik == 1
    error_message = "Expected traefik revision 1, got ${local.revisions.traefik}"
  }
}

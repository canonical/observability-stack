mock_provider "juju" {}

variables {
  model_uuid = "00000000-0000-0000-0000-000000000000"
}

# --- User revision pin is respected and not overridden by juju_charm datasource ---

run "user_revision_pin_is_respected" {
  command = plan

  variables {
    alertmanager            = { revision = 1 }
    catalogue               = { revision = 2 }
    grafana                 = { revision = 3 }
    loki_coordinator        = { revision = 4 }
    loki_worker             = { revision = 5 }
    mimir_coordinator       = { revision = 6 }
    mimir_worker            = { revision = 7 }
    opentelemetry_collector = { revision = 8 }
    seaweedfs               = { revision = 9 }
    s3_integrator           = { revision = 14 }
    ssc                     = { revision = 10 }
    tempo_coordinator       = { revision = 11 }
    tempo_worker            = { revision = 12 }
    traefik                 = { revision = 13 }
  }

  assert {
    condition     = local.revisions.alertmanager == 1
    error_message = "Expected alertmanager revision 1, got ${local.revisions.alertmanager}"
  }

  assert {
    condition     = local.revisions.catalogue == 2
    error_message = "Expected catalogue revision 2, got ${local.revisions.catalogue}"
  }

  assert {
    condition     = local.revisions.grafana == 3
    error_message = "Expected grafana revision 3, got ${local.revisions.grafana}"
  }

  assert {
    condition     = local.revisions.loki_coordinator == 4
    error_message = "Expected loki_coordinator revision 4, got ${local.revisions.loki_coordinator}"
  }

  assert {
    condition     = local.revisions.loki_worker == 5
    error_message = "Expected loki_worker revision 5, got ${local.revisions.loki_worker}"
  }

  assert {
    condition     = local.revisions.mimir_coordinator == 6
    error_message = "Expected mimir_coordinator revision 6, got ${local.revisions.mimir_coordinator}"
  }

  assert {
    condition     = local.revisions.mimir_worker == 7
    error_message = "Expected mimir_worker revision 7, got ${local.revisions.mimir_worker}"
  }

  assert {
    condition     = local.revisions.otelcol == 8
    error_message = "Expected otelcol revision 8, got ${local.revisions.otelcol}"
  }

  assert {
    condition     = local.revisions.seaweedfs == 9
    error_message = "Expected seaweedfs revision 9, got ${local.revisions.seaweedfs}"
  }

  assert {
    condition     = local.revisions.s3_integrator == 14
    error_message = "Expected s3_integrator revision 14, got ${local.revisions.s3_integrator}"
  }

  assert {
    condition     = local.revisions.ssc == 10
    error_message = "Expected ssc revision 10, got ${local.revisions.ssc}"
  }

  assert {
    condition     = local.revisions.tempo_coordinator == 11
    error_message = "Expected tempo_coordinator revision 11, got ${local.revisions.tempo_coordinator}"
  }

  assert {
    condition     = local.revisions.tempo_worker == 12
    error_message = "Expected tempo_worker revision 12, got ${local.revisions.tempo_worker}"
  }

  assert {
    condition     = local.revisions.traefik == 13
    error_message = "Expected traefik revision 13, got ${local.revisions.traefik}"
  }
}

# --- Without a revision pin, the juju_charm datasource determines the revision ---

run "no_pin_uses_datasource" {
  command = plan

  assert {
    condition     = local.revisions.alertmanager == data.juju_charm.alertmanager_info.revision
    error_message = "alertmanager revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.catalogue == data.juju_charm.catalogue_info.revision
    error_message = "catalogue revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.grafana == data.juju_charm.grafana_info.revision
    error_message = "grafana revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.loki_coordinator == data.juju_charm.loki_coordinator_info.revision
    error_message = "loki_coordinator revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.loki_worker == data.juju_charm.loki_worker_info.revision
    error_message = "loki_worker revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.mimir_coordinator == data.juju_charm.mimir_coordinator_info.revision
    error_message = "mimir_coordinator revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.mimir_worker == data.juju_charm.mimir_worker_info.revision
    error_message = "mimir_worker revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.otelcol == data.juju_charm.otelcol_info.revision
    error_message = "otelcol revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.seaweedfs == data.juju_charm.seaweedfs_info.revision
    error_message = "seaweedfs revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.s3_integrator == data.juju_charm.s3_integrator_info.revision
    error_message = "s3_integrator revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.ssc == data.juju_charm.ssc_info.revision
    error_message = "ssc revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.tempo_coordinator == data.juju_charm.tempo_coordinator_info.revision
    error_message = "tempo_coordinator revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.tempo_worker == data.juju_charm.tempo_worker_info.revision
    error_message = "tempo_worker revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.traefik == data.juju_charm.traefik_info.revision
    error_message = "traefik revision should come from datasource when no pin is set"
  }
}

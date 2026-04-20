mock_provider "juju" {}

variables { model_uuid = "00000000-0000-0000-0000-000000000000" }

# --- User revision pin is respected and not overridden by juju_charm datasource ---

run "user_revision_pin_is_respected" {
  command = plan

  variables {
    alertmanager = { revision = 1 }
    catalogue    = { revision = 2 }
    grafana      = { revision = 3 }
    loki         = { revision = 4 }
    prometheus   = { revision = 5 }
    ssc          = { revision = 6 }
    traefik      = { revision = 7 }
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
    condition     = local.revisions.loki == 4
    error_message = "Expected loki revision 4, got ${local.revisions.loki}"
  }

  assert {
    condition     = local.revisions.prometheus == 5
    error_message = "Expected prometheus revision 5, got ${local.revisions.prometheus}"
  }

  assert {
    condition     = local.revisions.ssc == 6
    error_message = "Expected ssc revision 6, got ${local.revisions.ssc}"
  }

  assert {
    condition     = local.revisions.traefik == 7
    error_message = "Expected traefik revision 7, got ${local.revisions.traefik}"
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
    condition     = local.revisions.loki == data.juju_charm.loki_info.revision
    error_message = "loki revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.prometheus == data.juju_charm.prometheus_info.revision
    error_message = "prometheus revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.ssc == data.juju_charm.ssc_info.revision
    error_message = "ssc revision should come from datasource when no pin is set"
  }

  assert {
    condition     = local.revisions.traefik == data.juju_charm.traefik_info.revision
    error_message = "traefik revision should come from datasource when no pin is set"
  }
}

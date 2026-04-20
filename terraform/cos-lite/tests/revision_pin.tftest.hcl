mock_provider "juju" {}

variables { model_uuid = "00000000-0000-0000-0000-000000000000" }

# --- User revision pin is respected and not overridden by juju_charm datasource ---

run "user_revision_pin_is_respected" {
  command = plan

  variables {
    alertmanager = { revision = 1 }
    catalogue    = { revision = 1 }
    grafana      = { revision = 1 }
    loki         = { revision = 1 }
    prometheus   = { revision = 1 }
    ssc          = { revision = 1 }
    traefik      = { revision = 1 }
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
    condition     = local.revisions.loki == 1
    error_message = "Expected loki revision 1, got ${local.revisions.loki}"
  }

  assert {
    condition     = local.revisions.prometheus == 1
    error_message = "Expected prometheus revision 1, got ${local.revisions.prometheus}"
  }

  assert {
    condition     = local.revisions.ssc == 1
    error_message = "Expected ssc revision 1, got ${local.revisions.ssc}"
  }

  assert {
    condition     = local.revisions.traefik == 1
    error_message = "Expected traefik revision 1, got ${local.revisions.traefik}"
  }
}

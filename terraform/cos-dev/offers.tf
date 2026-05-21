resource "juju_offer" "alertmanager_karma_dashboard" {
  name             = "alertmanager-karma-dashboard"
  model_uuid       = var.model_uuid
  application_name = module.alertmanager.app_name
  endpoints        = [module.alertmanager.provides.karma_dashboard]
}

resource "juju_offer" "grafana_dashboards" {
  name             = "grafana-dashboards"
  model_uuid       = var.model_uuid
  application_name = module.grafana.app_name
  endpoints        = [module.grafana.requires.grafana_dashboard]

  lifecycle { replace_triggered_by = [terraform_data.grafana_litestream_resource] }
}

resource "juju_offer" "loki_logging" {
  name             = "loki-logging"
  model_uuid       = var.model_uuid
  application_name = module.loki_coordinator.app_name
  endpoints        = ["logging"]
}

resource "juju_offer" "mimir_receive_remote_write" {
  name             = "mimir-receive-remote-write"
  model_uuid       = var.model_uuid
  application_name = module.mimir_coordinator.app_name
  endpoints        = ["receive-remote-write"]
}

resource "juju_offer" "tempo_tracing" {
  name             = "tempo-tracing"
  model_uuid       = var.model_uuid
  application_name = module.tempo_coordinator.app_name
  endpoints        = [module.tempo_coordinator.provides.tracing]
}

# -------------- # CMR Mesh offers -------------- #

resource "juju_offer" "alertmanager_provide_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "alertmanager-provide-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.alertmanager.app_name
  endpoints        = [module.alertmanager.provides.provide_cmr_mesh]
}

resource "juju_offer" "alertmanager_require_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "alertmanager-require-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.alertmanager.app_name
  endpoints        = [module.alertmanager.requires.require_cmr_mesh]
}

resource "juju_offer" "catalogue_provide_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "catalogue-provide-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.catalogue.app_name
  endpoints        = [module.catalogue.provides.provide_cmr_mesh]
}

resource "juju_offer" "catalogue_require_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "catalogue-require-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.catalogue.app_name
  endpoints        = [module.catalogue.requires.require_cmr_mesh]
}

resource "juju_offer" "grafana_provide_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "grafana-provide-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.grafana.app_name
  endpoints        = [module.grafana.provides.provide_cmr_mesh]

  lifecycle { replace_triggered_by = [terraform_data.grafana_litestream_resource] }
}

resource "juju_offer" "grafana_require_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "grafana-require-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.grafana.app_name
  endpoints        = [module.grafana.requires.require_cmr_mesh]

  lifecycle { replace_triggered_by = [terraform_data.grafana_litestream_resource] }
}

resource "juju_offer" "loki_provide_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "loki-provide-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.loki_coordinator.app_name
  endpoints        = [module.loki_coordinator.provides.provide_cmr_mesh]
}

resource "juju_offer" "loki_require_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "loki-require-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.loki_coordinator.app_name
  endpoints        = [module.loki_coordinator.requires.require_cmr_mesh]
}

resource "juju_offer" "mimir_provide_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "mimir-provide-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.mimir_coordinator.app_name
  endpoints        = [module.mimir_coordinator.provides.provide_cmr_mesh]
}

resource "juju_offer" "mimir_require_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "mimir-require-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.mimir_coordinator.app_name
  endpoints        = [module.mimir_coordinator.requires.require_cmr_mesh]
}

resource "juju_offer" "opentelemetry_collector_provide_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "opentelemetry-collector-provide-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.opentelemetry_collector.app_name
  endpoints        = [module.opentelemetry_collector.provides.provide_cmr_mesh]
}

resource "juju_offer" "opentelemetry_collector_require_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "opentelemetry-collector-require-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.opentelemetry_collector.app_name
  endpoints        = [module.opentelemetry_collector.requires.require_cmr_mesh]
}

resource "juju_offer" "tempo_provide_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "tempo-provide-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.tempo_coordinator.app_name
  endpoints        = [module.tempo_coordinator.provides.provide_cmr_mesh]
}

resource "juju_offer" "tempo_require_cmr_mesh" {
  count            = var.mesh_enabled ? 1 : 0
  name             = "tempo-require-cmr-mesh"
  model_uuid       = var.model_uuid
  application_name = module.tempo_coordinator.app_name
  endpoints        = [module.tempo_coordinator.requires.require_cmr_mesh]
}

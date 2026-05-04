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
  endpoints        = [module.loki_coordinator.provides.logging]
}

resource "juju_offer" "mimir_receive_remote_write" {
  name             = "mimir-receive-remote-write"
  model_uuid       = var.model_uuid
  application_name = module.mimir_coordinator.app_name
  endpoints        = [module.mimir_coordinator.provides.receive_remote_write]
}

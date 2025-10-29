resource "juju_offer" "alertmanager_karma_dashboard" {
  name             = "alertmanager-karma-dashboard"
  model_uuid = var.model_uuid
  application_name = module.alertmanager.app_name
  endpoints        = ["karma-dashboard"]
}

resource "juju_offer" "grafana_dashboards" {
  name             = "grafana-dashboards"
  model_uuid = var.model_uuid
  application_name = module.grafana.app_name
  endpoints        = ["grafana-dashboard"]
}

resource "juju_offer" "loki_logging" {
  name             = "loki-logging"
  model_uuid = var.model_uuid
  application_name = module.loki.app_names.loki_coordinator
  endpoints        = ["logging"]
}

resource "juju_offer" "mimir_receive_remote_write" {
  name             = "mimir-receive-remote-write"
  model_uuid = var.model_uuid
  application_name = module.mimir.app_names.mimir_coordinator
  endpoints        = ["receive-remote-write"]
}

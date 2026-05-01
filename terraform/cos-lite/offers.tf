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
  application_name = module.loki.app_name
  endpoints        = [module.loki.provides.logging]
}

resource "juju_offer" "prometheus_receive_remote_write" {
  name             = "prometheus-receive-remote-write"
  model_uuid       = var.model_uuid
  application_name = module.prometheus.app_name
  endpoints        = [module.prometheus.provides.receive_remote_write]
}

resource "juju_offer" "prometheus_metrics_endpoint" {
  name             = "prometheus-metrics-endpoint"
  model_uuid       = var.model_uuid
  application_name = module.prometheus.app_name
  endpoints        = [module.prometheus.provides.metrics_endpoint]
}

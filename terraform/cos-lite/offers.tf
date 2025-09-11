resource "juju_offer" "alertmanager_karma_dashboard" {
  name             = "alertmanager-karma-dashboard"
  model            = var.model
  application_name = module.alertmanager.app_name
  endpoints        = ["karma-dashboard"]
}

resource "juju_offer" "grafana_dashboards" {
  name             = "grafana-dashboards"
  model            = var.model
  application_name = module.grafana.app_name
  endpoints        = ["grafana-dashboard"]
}

resource "juju_offer" "loki_logging" {
  name             = "loki-logging"
  model            = var.model
  application_name = module.loki.app_name
  endpoints        = ["logging"]
}

resource "juju_offer" "prometheus_receive_remote_write" {
  name             = "prometheus-receive-remote-write"
  model            = var.model
  application_name = module.prometheus.app_name
  endpoints        = ["receive-remote-write"]
}

resource "juju_offer" "prometheus_scrape" {
  name             = "prometheus-scrape"
  model            = var.model
  application_name = module.prometheus.app_name
  endpoints        = ["metrics-endpoint"]
}

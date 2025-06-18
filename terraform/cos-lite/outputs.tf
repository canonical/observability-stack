# -------------- # Integration offers -------------- #

output "offers" {
  value = {
    alertmanager_karma_dashboard    = juju_offer.alertmanager-karma-dashboard
    grafana_dashboards              = juju_offer.grafana-dashboards
    loki_logging                    = juju_offer.loki-logging
    prometheus_receive_remote_write = juju_offer.prometheus-receive-remote-write
  }
}

# -------------- # Submodules -------------- #

output "components" {
  value = {
    alertmanager = module.alertmanager
    catalogue    = module.catalogue
    grafana      = module.grafana
    loki         = module.loki
    prometheus   = module.prometheus
    ssc          = module.ssc
    traefik      = module.traefik
  }
}
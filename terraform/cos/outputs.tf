# -------------- # Integration offers -------------- #

output "offers" {
  value = {
    alertmanager_karma_dashboard = juju_offer.alertmanager_karma_dashboard
    grafana_dashboards           = juju_offer.grafana_dashboards
    loki_logging                 = juju_offer.loki_logging
    mimir_receive_remote_write   = juju_offer.mimir_receive_remote_write
  }
}

# -------------- # Submodules -------------- #

output "components" {
  value = {
    alertmanager            = module.alertmanager
    catalogue               = module.catalogue
    grafana                 = module.grafana
    opentelemetry_collector = module.opentelemetry_collector
    loki                    = module.loki
    mimir                   = module.mimir
    ssc                     = module.ssc
    tempo                   = module.tempo
    traefik                 = module.traefik
  }
}

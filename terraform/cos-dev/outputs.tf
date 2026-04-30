# -------------- # Integration offers -------------- #

output "offers" {
  value = {
    alertmanager_karma_dashboard = juju_offer.alertmanager_karma_dashboard
    grafana_dashboards           = juju_offer.grafana_dashboards
    loki_logging                 = juju_offer.loki_logging
    mimir_receive_remote_write   = juju_offer.mimir_receive_remote_write
  }
  description = "All Juju offers which are exposed by this product module"
}

# -------------- # Submodules -------------- #

output "components" {
  value = {
    alertmanager            = module.alertmanager
    catalogue               = module.catalogue
    grafana                 = module.grafana
    loki_coordinator        = module.loki_coordinator
    loki_worker             = module.loki_worker
    mimir_coordinator       = module.mimir_coordinator
    mimir_worker            = module.mimir_worker
    opentelemetry_collector = module.opentelemetry_collector
    seaweedfs               = module.seaweedfs
    ssc                     = module.ssc
    tempo_coordinator       = module.tempo_coordinator
    tempo_worker            = module.tempo_worker
    traefik                 = module.traefik
  }
  description = "All Terraform charm modules which make up this product module"
}

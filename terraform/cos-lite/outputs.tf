# -------------- # Integration offers -------------- #

output "offers" {
  value = {
    alertmanager_karma_dashboard    = juju_offer.alertmanager_karma_dashboard
    grafana_dashboards              = juju_offer.grafana_dashboards
    loki_logging                    = juju_offer.loki_logging
    prometheus_receive_remote_write = juju_offer.prometheus_receive_remote_write
    prometheus_metrics_endpoint     = juju_offer.prometheus_metrics_endpoint
  }
  description = "All Juju offers which are exposed by this product module"
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
  description = "All Terraform charm modules which make up this product module"
}
# -------------- # Integration offers -------------- #

output "offers" {
  value = {
    alertmanager_karma_dashboard = juju_offer.alertmanager_karma_dashboard
    grafana_dashboards           = juju_offer.grafana_dashboards
    loki_logging                 = juju_offer.loki_logging
    mimir_receive_remote_write   = juju_offer.mimir_receive_remote_write
    tempo_tracing                = juju_offer.tempo_tracing
  }
  description = "All Juju offers which are exposed by this product module"
}

# -------------- # Submodules -------------- #

output "components" {
  value = {
    alertmanager                   = module.alertmanager
    catalogue                      = module.catalogue
    grafana                        = module.grafana
    loki_coordinator               = module.loki_coordinator
    loki_worker                    = try(module.loki_worker[0], null)
    loki_worker_backend            = try(module.loki_worker_backend[0], null)
    loki_worker_read               = try(module.loki_worker_read[0], null)
    loki_worker_write              = try(module.loki_worker_write[0], null)
    mimir_coordinator              = module.mimir_coordinator
    mimir_worker                   = try(module.mimir_worker[0], null)
    mimir_worker_backend           = try(module.mimir_worker_backend[0], null)
    mimir_worker_read              = try(module.mimir_worker_read[0], null)
    mimir_worker_write             = try(module.mimir_worker_write[0], null)
    opentelemetry_collector        = module.opentelemetry_collector
    seaweedfs                      = try(module.seaweedfs[0], null)
    ssc                            = module.ssc
    tempo_coordinator              = module.tempo_coordinator
    tempo_worker                   = try(module.tempo_worker[0], null)
    tempo_worker_querier           = try(module.tempo_worker_querier[0], null)
    tempo_worker_query_frontend    = try(module.tempo_worker_query_frontend[0], null)
    tempo_worker_ingester          = try(module.tempo_worker_ingester[0], null)
    tempo_worker_distributor       = try(module.tempo_worker_distributor[0], null)
    tempo_worker_compactor         = try(module.tempo_worker_compactor[0], null)
    tempo_worker_metrics_generator = try(module.tempo_worker_metrics_generator[0], null)
    traefik                        = module.traefik
  }
  description = "All Terraform charm modules which make up this product module"
}

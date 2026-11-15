# -------------- # Integration offers -------------- #

output "offers" {
  value = {
    alertmanager_karma_dashboard = juju_offer.alertmanager_karma_dashboard
    grafana_dashboards           = juju_offer.grafana_dashboards
    loki_logging                 = juju_offer.loki_logging
    mimir_receive_remote_write   = juju_offer.mimir_receive_remote_write
    otelcol_receive_otlp         = juju_offer.otelcol_receive_otlp
    otelcol_receive_traces       = juju_offer.otelcol_receive_traces
  }
  description = "All Juju offers which are exposed by this product module"
}

# The integration interface consumers wire to: every offer this product
# exposes, keyed by the Juju interface it satisfies and given as its offer URL.
# A consumer names the interfaces it requires and Terraform ignores the rest,
# so a product can expose every interface while a consumer takes only the ones
# it uses. Every product module names this output `interfaces`, so a consumer
# wires to any of them the same way. `offers` above stays the raw Juju surface.
output "interfaces" {
  description = "Every offer this product exposes, keyed by the Juju interface it satisfies, as offer URLs."
  type = object({
    grafana_dashboard       = string
    karma_dashboard         = string
    loki_push_api           = string
    otlp                    = string
    prometheus_remote_write = string
    tracing                 = string
  })
  value = {
    grafana_dashboard       = juju_offer.grafana_dashboards.url
    karma_dashboard         = juju_offer.alertmanager_karma_dashboard.url
    loki_push_api           = juju_offer.loki_logging.url
    otlp                    = juju_offer.otelcol_receive_otlp.url
    prometheus_remote_write = juju_offer.mimir_receive_remote_write.url
    tracing                 = juju_offer.otelcol_receive_traces.url
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
    ssc                     = try(module.ssc[0], null)
    tempo                   = module.tempo
    traefik                 = try(module.traefik[0], null)
  }
  description = "All Terraform charm modules which make up this product module"
}

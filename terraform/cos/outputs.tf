# -------------- # Integration offers -------------- #

output "offers" {
  value       = local.offers
  description = "All Juju offers which are exposed by this product module"
}

# The integration interface consumers wire to: every offer this product
# exposes, keyed by the Juju interface it satisfies and given as its offer URL.
# A consumer names the interfaces it requires and Terraform ignores the rest,
# so COS can offer every interface while a consumer takes only the ones it uses.
# COS defines this interface; any product integrating with COS implements a
# matching input.
output "cos_offers" {
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
    grafana_dashboard       = local.offers.grafana_dashboards.url
    karma_dashboard         = local.offers.alertmanager_karma_dashboard.url
    loki_push_api           = local.offers.loki_logging.url
    otlp                    = local.offers.otelcol_receive_otlp.url
    prometheus_remote_write = local.offers.mimir_receive_remote_write.url
    tracing                 = local.offers.otelcol_receive_traces.url
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

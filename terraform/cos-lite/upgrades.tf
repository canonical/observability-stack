# -------------- # Replace triggers -------------- #

# -- Grafana -- #

# [application] Removed the litestream-image resource
#   Given a Juju bug, we need to trigger application replacement, otherwise the upgrade will fail
#   https://github.com/juju/juju/issues/21648
#   https://github.com/juju/juju/issues/22071
resource "terraform_data" "grafana_litestream_resource" {
  triggers_replace = contains(keys(data.juju_charm.grafana_info.resources), "litestream-image")
}

# [integration] Ingress interface changed
#   The ingress endpoint interface changes from traefik_route to ingress_per_app so we need to
#   trigger integration replacement, otherwise the upgrade will fail
#   https://github.com/canonical/observability-stack/issues/165
resource "terraform_data" "grafana_ingress_interface" {
  triggers_replace = lookup(data.juju_charm.grafana_info.requires, "ingress", "")
}

# -------------- # CharmHub API -------------- #

data "juju_charm" "alertmanager_info" {
  charm   = "alertmanager-k8s"
  channel = local.channels.alertmanager
  base    = var.base
}

data "juju_charm" "catalogue_info" {
  charm   = "catalogue-k8s"
  channel = local.channels.catalogue
  base    = var.base
}

data "juju_charm" "grafana_info" {
  charm   = "grafana-k8s"
  channel = local.channels.grafana
  base    = var.base
}

data "juju_charm" "loki_info" {
  charm   = "loki-k8s"
  channel = local.channels.loki
  base    = var.base
}

data "juju_charm" "prometheus_info" {
  charm   = "prometheus-k8s"
  channel = local.channels.prometheus
  base    = var.base
}

data "juju_charm" "ssc_info" {
  charm   = "self-signed-certificates"
  channel = local.channels.ssc
  base    = var.base
}

data "juju_charm" "traefik_info" {
  charm   = "traefik-k8s"
  channel = local.channels.traefik
  base    = local.traefik_base
}

# -------------- # State migrations -------------- #

# refactor: Traefik and SSC are conditional (#353)
moved {
  from = module.traefik
  to   = module.traefik[0]
}

# refactor: collapse per-app integrations into for_each loops
moved {
  from = juju_integration.alertmanager_grafana_dashboards
  to   = juju_integration.grafana_dashboards["alertmanager"]
}

moved {
  from = juju_integration.prometheus_grafana_dashboards_provider
  to   = juju_integration.grafana_dashboards["prometheus"]
}

moved {
  from = juju_integration.loki_grafana_dashboards_provider
  to   = juju_integration.grafana_dashboards["loki"]
}

moved {
  from = juju_integration.grafana_source_alertmanager
  to   = juju_integration.grafana_sources["alertmanager"]
}

moved {
  from = juju_integration.prometheus_grafana_source
  to   = juju_integration.grafana_sources["prometheus"]
}

moved {
  from = juju_integration.loki_grafana_source
  to   = juju_integration.grafana_sources["loki"]
}

moved {
  from = juju_integration.alertmanager_prometheus
  to   = juju_integration.alerting["prometheus"]
}

moved {
  from = juju_integration.alertmanager_loki
  to   = juju_integration.alerting["loki"]
}

moved {
  from = juju_integration.alertmanager_self_monitoring_prometheus
  to   = juju_integration.metrics_endpoint["alertmanager"]
}

moved {
  from = juju_integration.grafana_self_monitoring_prometheus
  to   = juju_integration.metrics_endpoint["grafana"]
}

moved {
  from = juju_integration.loki_self_monitoring_prometheus
  to   = juju_integration.metrics_endpoint["loki"]
}

moved {
  from = juju_integration.catalogue_alertmanager
  to   = juju_integration.catalogue_integrations["alertmanager"]
}

moved {
  from = juju_integration.catalogue_prometheus
  to   = juju_integration.catalogue_integrations["prometheus"]
}

moved {
  from = juju_integration.catalogue_grafana
  to   = juju_integration.catalogue_integrations["grafana"]
}

moved {
  from = juju_integration.external_grafana_ca_cert[0]
  to   = juju_integration.external_ca_cert["grafana"]
}

moved {
  from = juju_integration.external_prom_ca_cert[0]
  to   = juju_integration.external_ca_cert["prometheus"]
}

# refactor: move integrations after for_each loop implementation
moved {
  from = juju_integration.alertmanager_certificates[0]
  to   = juju_integration.internal_certificates["alertmanager"]
}

moved {
  from = juju_integration.catalogue_certificates[0]
  to   = juju_integration.internal_certificates["catalogue"]
}

moved {
  from = juju_integration.grafana_certificates[0]
  to   = juju_integration.internal_certificates["grafana"]
}

moved {
  from = juju_integration.loki_certificates[0]
  to   = juju_integration.internal_certificates["loki"]
}

moved {
  from = juju_integration.prometheus_certificates[0]
  to   = juju_integration.internal_certificates["prometheus"]
}

# refactor: collapse per-app ingress into the ingress/ingress_per_unit for_each loops
moved {
  from = juju_integration.alertmanager_ingress
  to   = juju_integration.ingress["alertmanager"]
}

moved {
  from = juju_integration.catalogue_ingress
  to   = juju_integration.ingress["catalogue"]
}

moved {
  from = juju_integration.loki_ingress
  to   = juju_integration.ingress_per_unit["loki"]
}

moved {
  from = juju_integration.prometheus_ingress
  to   = juju_integration.ingress_per_unit["prometheus"]
}

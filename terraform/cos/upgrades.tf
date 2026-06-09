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

data "juju_charm" "loki_coordinator_info" {
  charm   = "loki-coordinator-k8s"
  channel = local.channels.loki
  base    = var.base
}

data "juju_charm" "loki_worker_info" {
  charm   = "loki-worker-k8s"
  channel = local.channels.loki
  base    = var.base
}

data "juju_charm" "mimir_coordinator_info" {
  charm   = "mimir-coordinator-k8s"
  channel = local.channels.mimir
  base    = var.base
}

data "juju_charm" "mimir_worker_info" {
  charm   = "mimir-worker-k8s"
  channel = local.channels.mimir
  base    = var.base
}

data "juju_charm" "otelcol_info" {
  charm   = "opentelemetry-collector-k8s"
  channel = local.channels.otelcol
  base    = var.base
}

data "juju_charm" "tempo_coordinator_info" {
  charm   = "tempo-coordinator-k8s"
  channel = local.channels.tempo
  base    = var.base
}

data "juju_charm" "tempo_worker_info" {
  charm   = "tempo-worker-k8s"
  channel = local.channels.tempo
  base    = var.base
}

data "juju_charm" "ssc_info" {
  charm   = "self-signed-certificates"
  channel = local.channels.ssc
  base    = var.base
}

data "juju_charm" "s3_integrator_info" {
  charm   = "s3-integrator"
  channel = local.channels.s3_integrator
  base    = var.base
}

data "juju_charm" "traefik_info" {
  charm   = "traefik-k8s"
  channel = local.channels.traefik
  base    = local.traefik_base
}

# -------------- # State migrations -------------- #

# refactor: Traefik and SSC are conditional (#354)
moved {
  from = module.traefik
  to   = module.traefik[0]
}

# refactor: align metrics-endpoint loop name with cos-lite
moved {
  from = juju_integration.otelcol_metrics_endpoint
  to   = juju_integration.metrics_endpoint
}

# refactor: collapse mimir receive-remote-write integrations into a for_each loop
moved {
  from = juju_integration.opentelemetry_collector_mimir_metrics
  to   = juju_integration.receive_remote_write["opentelemetry_collector"]
}

moved {
  from = juju_integration.tempo_send_remote_write_mimir_receive_remote_write
  to   = juju_integration.receive_remote_write["tempo"]
}

# refactor: collapse datasource-exchange correlations into a for_each loop
moved {
  from = juju_integration.traces_and_logs_correlation
  to   = juju_integration.receive_datasource["loki"]
}

moved {
  from = juju_integration.traces_and_metrics_correlation
  to   = juju_integration.receive_datasource["mimir"]
}

# refactor: collapse external CA-cert integrations into a for_each loop
moved {
  from = juju_integration.external_grafana_ca_cert[0]
  to   = juju_integration.external_ca_cert["grafana"]
}

moved {
  from = juju_integration.external_otelcol_ca_cert[0]
  to   = juju_integration.external_ca_cert["opentelemetry_collector"]
}

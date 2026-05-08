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

data "juju_charm" "seaweedfs_info" {
  charm   = "seaweedfs-k8s"
  channel = local.channels.seaweedfs
  base    = var.base
}

data "juju_charm" "ssc_info" {
  charm   = "self-signed-certificates"
  channel = local.channels.ssc
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

# -------------- # CharmHub API -------------- #

# TODO: Add a utest to assert that a user revision pin is respected and doesn't get overridden by the juju-charm datasource.
# TODO: assert that if a user doesn't provide a revision pin then the juju-charm datasource is used to determine the revision.
# TODO: We want one per component to avoid mistakes not applied to all components.
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
  charm   = "s3-integrator-k8s"
  channel = local.channels.s3_integrator
  base    = var.base
}

data "juju_charm" "traefik_info" {
  charm   = "traefik-k8s"
  channel = local.channels.traefik
  base    = var.base
}

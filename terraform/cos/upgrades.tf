data "juju_charm" "alertmanager_info" {
  charm   = "alertmanager-k8s"
  channel = local.tracks.alertmanager + "/" + var.risk
  base    = var.base
}

data "juju_charm" "catalogue_info" {
  charm   = "catalogue-k8s"
  channel = local.tracks.catalogue + "/" + var.risk
  base    = var.base
}

data "juju_charm" "grafana_info" {
  charm   = "grafana-k8s"
  channel = local.tracks.grafana + "/" + var.risk
  base    = var.base
}

data "juju_charm" "loki_coordinator_info" {
  charm   = "loki-coordinator-k8s"
  channel = local.tracks.loki + "/" + var.risk
  base    = var.base
}

data "juju_charm" "loki_worker_info" {
  charm   = "loki-worker-k8s"
  channel = local.tracks.loki + "/" + var.risk
  base    = var.base
}

data "juju_charm" "mimir_coordinator_info" {
  charm   = "mimir-coordinator-k8s"
  channel = local.tracks.mimir + "/" + var.risk
  base    = var.base
}

data "juju_charm" "mimir_worker_info" {
  charm   = "mimir-worker-k8s"
  channel = local.tracks.mimir + "/" + var.risk
  base    = var.base
}

data "juju_charm" "otelcol_info" {
  charm   = "opentelemetry-collector-k8s"
  channel = local.tracks.otelcol + "/" + var.risk
  base    = var.base
}

data "juju_charm" "tempo_coordinator_info" {
  charm   = "tempo-coordinator-k8s"
  channel = local.tracks.tempo + "/" + var.risk
  base    = var.base
}

data "juju_charm" "tempo_worker_info" {
  charm   = "tempo-worker-k8s"
  channel = local.tracks.tempo + "/" + var.risk
  base    = var.base
}

data "juju_charm" "ssc_info" {
  charm   = "self-signed-certificates"
  channel = local.tracks.ssc + "/" + var.risk
  base    = var.base
}

data "juju_charm" "traefik_info" {
  charm   = "traefik-k8s"
  channel = local.tracks.traefik + "/" + var.risk
  base    = var.base
}
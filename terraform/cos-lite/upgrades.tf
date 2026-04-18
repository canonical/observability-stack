# TODO: If we only use the juju-charm datasource then users won't be able to revision pin

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

data "juju_charm" "loki_info" {
  charm   = "loki-k8s"
  channel = local.tracks.loki + "/" + var.risk
  base    = var.base
}

data "juju_charm" "prometheus_info" {
  charm   = "prometheus-k8s"
  channel = local.tracks.prometheus + "/" + var.risk
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
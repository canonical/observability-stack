# TODO: If we only use the juju-charm datasource then users won't be able to revision pin

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
  base    = var.base
}

locals {
  # Model resolution: prefer legacy var.model_uuid, then var.model.uuid, else create.
  provided_model_uuid = coalesce(var.model_uuid, var.model.uuid, null)
  create_model        = local.provided_model_uuid == null
  model_uuid          = local.create_model ? juju_model.cos[0].uuid : data.juju_model.cos[0].uuid

  tls_termination       = var.external_certificates_offer_url != null ? true : false
  reverse_proxy_enabled = anytrue(values(var.ingress))
  traefik_enabled       = local.reverse_proxy_enabled
  traefik_base          = "ubuntu@20.04"
  tracks = {
    alertmanager = "dev"
    catalogue    = "dev"
    grafana      = "dev"
    loki         = "dev"
    prometheus   = "dev"

    ssc     = "1"
    traefik = "latest"
  }
  channels = {
    alertmanager = "${local.tracks.alertmanager}/${var.risk}"
    catalogue    = "${local.tracks.catalogue}/${var.risk}"
    grafana      = "${local.tracks.grafana}/${var.risk}"
    loki         = "${local.tracks.loki}/${var.risk}"
    prometheus   = "${local.tracks.prometheus}/${var.risk}"
    ssc          = "${local.tracks.ssc}/${var.risk}"
    traefik      = "${local.tracks.traefik}/${var.risk}"
  }
  revisions = {
    alertmanager = var.alertmanager.revision != null ? var.alertmanager.revision : data.juju_charm.alertmanager_info.revision
    catalogue    = var.catalogue.revision != null ? var.catalogue.revision : data.juju_charm.catalogue_info.revision
    grafana      = var.grafana.revision != null ? var.grafana.revision : data.juju_charm.grafana_info.revision
    loki         = var.loki.revision != null ? var.loki.revision : data.juju_charm.loki_info.revision
    prometheus   = var.prometheus.revision != null ? var.prometheus.revision : data.juju_charm.prometheus_info.revision
    ssc          = var.ssc.revision != null ? var.ssc.revision : data.juju_charm.ssc_info.revision
    traefik      = var.traefik.revision != null ? var.traefik.revision : data.juju_charm.traefik_info.revision
  }
}

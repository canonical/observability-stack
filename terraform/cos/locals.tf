locals {
  clouds          = ["aws", "self-managed"] # list of k8s clouds where this COS module can be deployed.
  tls_termination = var.external_certificates_offer_url != null ? true : false
  traefik_base    = "ubuntu@20.04"
  tracks = {
    alertmanager = "dev"
    catalogue    = "dev"
    grafana      = "dev"
    loki         = "dev"
    mimir        = "dev"
    otelcol      = "dev"
    tempo        = "dev"

    # alertmanager  = "0.31"
    # catalogue     = "3.0"
    # grafana       = "12.4"
    # loki          = "3.7"
    # mimir         = "3.0"
    # otelcol       = "0.130"
    s3_integrator = "2"
    ssc           = "1"
    # tempo         = "2.10"
    traefik = "latest"
  }
  channels = {
    alertmanager  = "${local.tracks.alertmanager}/${var.risk}"
    catalogue     = "${local.tracks.catalogue}/${var.risk}"
    grafana       = "${local.tracks.grafana}/${var.risk}"
    loki          = "${local.tracks.loki}/${var.risk}"
    mimir         = "${local.tracks.mimir}/${var.risk}"
    otelcol       = "${local.tracks.otelcol}/${var.risk}"
    s3_integrator = "${local.tracks.s3_integrator}/${var.risk}"
    ssc           = "${local.tracks.ssc}/${var.risk}"
    tempo         = "${local.tracks.tempo}/${var.risk}"
    traefik       = "${local.tracks.traefik}/${var.risk}"
  }
  revisions = {
    alertmanager      = var.alertmanager.revision != null ? var.alertmanager.revision : data.juju_charm.alertmanager_info.revision
    catalogue         = var.catalogue.revision != null ? var.catalogue.revision : data.juju_charm.catalogue_info.revision
    grafana           = var.grafana.revision != null ? var.grafana.revision : data.juju_charm.grafana_info.revision
    loki_coordinator  = var.loki_coordinator.revision != null ? var.loki_coordinator.revision : data.juju_charm.loki_coordinator_info.revision
    loki_worker       = var.loki_worker.revision != null ? var.loki_worker.revision : data.juju_charm.loki_worker_info.revision
    mimir_coordinator = var.mimir_coordinator.revision != null ? var.mimir_coordinator.revision : data.juju_charm.mimir_coordinator_info.revision
    mimir_worker      = var.mimir_worker.revision != null ? var.mimir_worker.revision : data.juju_charm.mimir_worker_info.revision
    otelcol           = var.opentelemetry_collector.revision != null ? var.opentelemetry_collector.revision : data.juju_charm.otelcol_info.revision
    s3_integrator     = var.s3_integrator.revision != null ? var.s3_integrator.revision : data.juju_charm.s3_integrator_info.revision
    ssc               = var.ssc.revision != null ? var.ssc.revision : data.juju_charm.ssc_info.revision
    tempo_coordinator = var.tempo_coordinator.revision != null ? var.tempo_coordinator.revision : data.juju_charm.tempo_coordinator_info.revision
    tempo_worker      = var.tempo_worker.revision != null ? var.tempo_worker.revision : data.juju_charm.tempo_worker_info.revision
    traefik           = var.traefik.revision != null ? var.traefik.revision : data.juju_charm.traefik_info.revision
  }
}

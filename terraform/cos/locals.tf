locals {
  clouds                     = ["aws", "self-managed"] # list of k8s clouds where this COS module can be deployed.
  create_model               = var.model.uuid == null
  grafana_db_enabled         = var.postgresql_offer_url != null
  istio_ingress_enabled      = local.reverse_proxy_enabled && var.mesh_enabled
  model_uuid                 = local.create_model ? juju_model.cos[0].uuid : data.juju_model.cos[0].uuid
  reverse_proxy_enabled      = anytrue(values(var.ingress))
  storage_directives_warning = "is unset, so it will use the default 1G volume. Set a size before deploying to production; resizing a persistent volume after deployment requires manual steps. See https://documentation.ubuntu.com/observability/latest/how-to/configure-and-tune/customize-storage-options/"
  tls_termination            = var.external_certificates_offer_url != null ? true : false
  traefik_enabled            = local.reverse_proxy_enabled && !var.mesh_enabled
  bases = {
    istio_beacon  = "ubuntu@22.04"
    istio_ingress = "ubuntu@24.04"
    o11y          = "ubuntu@26.04"
    s3_integrator = "ubuntu@24.04"
    ssc           = "ubuntu@24.04"
    traefik       = "ubuntu@26.04"
  }
  channels = {
    alertmanager  = "${local.tracks.alertmanager}/${var.risk}"
    catalogue     = "${local.tracks.catalogue}/${var.risk}"
    grafana       = "${local.tracks.grafana}/${var.risk}"
    istio_beacon  = "${local.tracks.istio_beacon}/${var.risk}"
    istio_ingress = "${local.tracks.istio_ingress}/${var.risk}"
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
    istio_beacon      = var.istio_beacon.revision != null ? var.istio_beacon.revision : data.juju_charm.istio_beacon_info.revision
    istio_ingress     = var.istio_ingress.revision != null ? var.istio_ingress.revision : data.juju_charm.istio_ingress_info.revision
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
  tracks = {
    alertmanager  = "dev"
    catalogue     = "dev"
    grafana       = "dev"
    istio_beacon  = "dev"
    istio_ingress = "dev"
    loki          = "dev"
    mimir         = "dev"
    otelcol       = "dev"
    tempo         = "dev"
    # external charms
    s3_integrator = "2"
    ssc           = "1"
    traefik       = "latest"
  }
}

locals {
  clouds                     = ["aws", "self-managed"] # list of k8s clouds where this COS module can be deployed.
  create_model               = var.model.uuid == null
  grafana_db_enabled         = var.postgresql_offer_url != null
  model_uuid                 = local.create_model ? juju_model.cos[0].uuid : data.juju_model.cos[0].uuid
  reverse_proxy_enabled      = anytrue(values(local.values.ingress))
  storage_directives_warning = "is unset, so it will use the default 1G volume. Set a size before deploying to production; resizing a persistent volume after deployment requires manual steps. See https://documentation.ubuntu.com/observability/latest/how-to/configure-and-tune/customize-storage-options/"
  tls_termination            = var.external_certificates_offer_url != null ? true : false
  traefik_enabled            = local.reverse_proxy_enabled
  bases = {
    o11y          = "ubuntu@26.04"
    s3_integrator = "ubuntu@24.04"
    ssc           = "ubuntu@24.04"
    traefik       = "ubuntu@26.04"
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
    alertmanager      = local.values.alertmanager.revision != null ? local.values.alertmanager.revision : data.juju_charm.alertmanager_info.revision
    catalogue         = local.values.catalogue.revision != null ? local.values.catalogue.revision : data.juju_charm.catalogue_info.revision
    grafana           = local.values.grafana.revision != null ? local.values.grafana.revision : data.juju_charm.grafana_info.revision
    loki_coordinator  = local.values.loki_coordinator.revision != null ? local.values.loki_coordinator.revision : data.juju_charm.loki_coordinator_info.revision
    loki_worker       = local.values.loki_worker.revision != null ? local.values.loki_worker.revision : data.juju_charm.loki_worker_info.revision
    mimir_coordinator = local.values.mimir_coordinator.revision != null ? local.values.mimir_coordinator.revision : data.juju_charm.mimir_coordinator_info.revision
    mimir_worker      = local.values.mimir_worker.revision != null ? local.values.mimir_worker.revision : data.juju_charm.mimir_worker_info.revision
    otelcol           = local.values.opentelemetry_collector.revision != null ? local.values.opentelemetry_collector.revision : data.juju_charm.otelcol_info.revision
    s3_integrator     = local.values.s3_integrator.revision != null ? local.values.s3_integrator.revision : data.juju_charm.s3_integrator_info.revision
    ssc               = local.values.ssc.revision != null ? local.values.ssc.revision : data.juju_charm.ssc_info.revision
    tempo_coordinator = local.values.tempo_coordinator.revision != null ? local.values.tempo_coordinator.revision : data.juju_charm.tempo_coordinator_info.revision
    tempo_worker      = local.values.tempo_worker.revision != null ? local.values.tempo_worker.revision : data.juju_charm.tempo_worker_info.revision
    traefik           = local.values.traefik.revision != null ? local.values.traefik.revision : data.juju_charm.traefik_info.revision
  }
  tracks = {
    alertmanager = "dev"
    catalogue    = "dev"
    grafana      = "dev"
    loki         = "dev"
    mimir        = "dev"
    otelcol      = "dev"
    tempo        = "dev"
    # external charms
    s3_integrator = "2"
    ssc           = "1"
    traefik       = "latest"
  }
}

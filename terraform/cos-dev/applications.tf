module "alertmanager" {
  source             = "git::https://github.com/canonical/alertmanager-k8s-operator//terraform"
  app_name           = var.alertmanager.app_name
  channel            = local.channels.alertmanager
  config             = var.alertmanager.config
  constraints        = var.alertmanager.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.alertmanager
  storage_directives = var.alertmanager.storage_directives
  units              = var.alertmanager.units
}

module "catalogue" {
  source             = "git::https://github.com/canonical/catalogue-k8s-operator//terraform"
  app_name           = var.catalogue.app_name
  channel            = local.channels.catalogue
  config             = var.catalogue.config
  constraints        = var.catalogue.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.catalogue
  storage_directives = var.catalogue.storage_directives
  units              = var.catalogue.units
}

module "grafana" {
  source             = "git::https://github.com/canonical/grafana-k8s-operator//terraform"
  app_name           = var.grafana.app_name
  channel            = local.channels.grafana
  config             = var.grafana.config
  constraints        = var.grafana.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.grafana
  storage_directives = var.grafana.storage_directives
  units              = var.grafana.units
  replace_triggers   = [terraform_data.grafana_litestream_resource.id]
}

module "loki_coordinator" {
  source             = "git::https://github.com/canonical/loki-operators//coordinator/terraform"
  app_name           = var.loki_coordinator.app_name
  channel            = local.channels.loki
  config             = var.loki_coordinator.config
  constraints        = var.loki_coordinator.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.loki_coordinator
  storage_directives = var.loki_coordinator.storage_directives
  units              = var.loki_coordinator.units
}

module "loki_worker" {
  source     = "git::https://github.com/canonical/loki-operators//worker/terraform"
  depends_on = [module.loki_coordinator]

  app_name           = var.loki_worker.app_name
  channel            = local.channels.loki
  config             = merge({ "role-all" = "true" }, var.loki_worker.config)
  constraints        = var.loki_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.loki_worker
  storage_directives = var.loki_worker.storage_directives
  units              = var.loki_worker.units
}

module "mimir_coordinator" {
  source             = "git::https://github.com/canonical/mimir-operators//coordinator/terraform"
  app_name           = var.mimir_coordinator.app_name
  channel            = local.channels.mimir
  config             = var.mimir_coordinator.config
  constraints        = var.mimir_coordinator.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.mimir_coordinator
  storage_directives = var.mimir_coordinator.storage_directives
  units              = var.mimir_coordinator.units
}

module "mimir_worker" {
  source     = "git::https://github.com/canonical/mimir-operators//worker/terraform"
  depends_on = [module.mimir_coordinator]

  app_name           = var.mimir_worker.app_name
  channel            = local.channels.mimir
  config             = merge({ "role-all" = "true" }, var.mimir_worker.config)
  constraints        = var.mimir_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.mimir_worker
  storage_directives = var.mimir_worker.storage_directives
  units              = var.mimir_worker.units
}

module "opentelemetry_collector" {
  source             = "git::https://github.com/canonical/opentelemetry-collector-k8s-operator//terraform"
  app_name           = var.opentelemetry_collector.app_name
  channel            = local.channels.otelcol
  config             = var.opentelemetry_collector.config
  constraints        = var.opentelemetry_collector.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.otelcol
  storage_directives = var.opentelemetry_collector.storage_directives
  units              = var.opentelemetry_collector.units
}

module "seaweedfs" {
  source             = "git::https://github.com/canonical/observability-stack//terraform/seaweedfs"
  app_name           = var.seaweedfs.app_name
  channel            = local.channels.seaweedfs
  config             = var.seaweedfs.config
  constraints        = var.seaweedfs.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.seaweedfs
  storage_directives = var.seaweedfs.storage_directives
  units              = var.seaweedfs.units
}

module "ssc" {
  count       = var.internal_tls ? 1 : 0
  source      = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  app_name    = var.ssc.app_name
  channel     = local.channels.ssc
  config      = var.ssc.config
  constraints = var.ssc.constraints
  model_uuid  = var.model_uuid
  revision    = local.revisions.ssc
  units       = var.ssc.units
}

module "tempo_coordinator" {
  source             = "git::https://github.com/canonical/tempo-operators//coordinator/terraform"
  app_name           = var.tempo_coordinator.app_name
  channel            = local.channels.tempo
  config             = var.tempo_coordinator.config
  constraints        = var.tempo_coordinator.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.tempo_coordinator
  storage_directives = var.tempo_coordinator.storage_directives
  units              = var.tempo_coordinator.units
}

module "tempo_worker" {
  source     = "git::https://github.com/canonical/tempo-operators//worker/terraform"
  depends_on = [module.tempo_coordinator]

  app_name           = var.tempo_worker.app_name
  channel            = local.channels.tempo
  config             = merge({ "role-all" = "true" }, var.tempo_worker.config)
  constraints        = var.tempo_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.tempo_worker
  storage_directives = var.tempo_worker.storage_directives
  units              = var.tempo_worker.units
}

module "traefik" {
  source             = "git::https://github.com/canonical/traefik-k8s-operator//terraform"
  app_name           = var.traefik.app_name
  channel            = local.channels.traefik
  config             = var.traefik.config
  constraints        = var.traefik.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.traefik
  storage_directives = var.traefik.storage_directives
  units              = var.traefik.units
}

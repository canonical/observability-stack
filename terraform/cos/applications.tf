module "alertmanager" {
  source = "git::https://github.com/canonical/alertmanager-k8s-operator//terraform"

  app_name           = local.values.alertmanager.app_name
  base               = local.bases.o11y
  channel            = local.channels.alertmanager
  config             = local.values.alertmanager.config
  constraints        = local.values.alertmanager.constraints
  model_uuid         = local.model_uuid
  resources          = local.values.alertmanager.resources
  revision           = local.revisions.alertmanager
  storage_directives = local.values.alertmanager.storage_directives
  units              = local.values.alertmanager.units
}

module "catalogue" {
  source = "git::https://github.com/canonical/catalogue-k8s-operator//charm/terraform"

  app_name           = local.values.catalogue.app_name
  base               = local.bases.o11y
  channel            = local.channels.catalogue
  config             = local.values.catalogue.config
  constraints        = local.values.catalogue.constraints
  model_uuid         = local.model_uuid
  resources          = local.values.catalogue.resources
  revision           = local.revisions.catalogue
  storage_directives = local.values.catalogue.storage_directives
  units              = local.values.catalogue.units
}

module "grafana" {
  source = "git::https://github.com/canonical/grafana-k8s-operator//terraform"

  app_name           = local.values.grafana.app_name
  base               = local.bases.o11y
  channel            = local.channels.grafana
  config             = local.values.grafana.config
  constraints        = local.values.grafana.constraints
  model_uuid         = local.model_uuid
  resources          = local.values.grafana.resources
  revision           = local.revisions.grafana
  storage_directives = local.values.grafana.storage_directives
  units              = local.values.grafana.units
  replace_triggers   = [terraform_data.grafana_litestream_resource.id]
}

module "loki" {
  source = "git::https://github.com/canonical/loki-operators//terraform"

  anti_affinity                     = local.values.anti_affinity
  base                              = local.bases.o11y
  channel                           = local.channels.loki
  model_uuid                        = local.model_uuid
  s3_endpoint                       = var.s3_endpoint
  s3_secret_key                     = var.s3_secret_key
  s3_access_key                     = var.s3_access_key
  s3_bucket                         = var.loki_bucket
  s3_integrator_base                = local.bases.s3_integrator
  s3_integrator_channel             = local.channels.s3_integrator
  s3_integrator_config              = local.values.s3_integrator.config
  s3_integrator_constraints         = local.values.s3_integrator.constraints
  s3_integrator_revision            = local.revisions.s3_integrator
  s3_integrator_storage_directives  = local.values.s3_integrator.storage_directives
  s3_integrator_units               = local.values.s3_integrator.units
  coordinator_config                = local.values.loki_coordinator.config
  coordinator_constraints           = local.values.loki_coordinator.constraints
  coordinator_resources             = local.values.loki_coordinator.resources
  coordinator_revision              = local.revisions.loki_coordinator
  coordinator_storage_directives    = local.values.loki_coordinator.storage_directives
  coordinator_units                 = local.values.loki_coordinator.units
  backend_config                    = local.values.loki_worker.backend_config
  read_config                       = local.values.loki_worker.read_config
  write_config                      = local.values.loki_worker.write_config
  worker_constraints                = local.values.loki_worker.constraints
  worker_resources                  = local.values.loki_worker.resources
  worker_revision                   = local.revisions.loki_worker
  backend_worker_storage_directives = local.values.loki_worker.backend_storage_directives
  read_worker_storage_directives    = local.values.loki_worker.read_storage_directives
  write_worker_storage_directives   = local.values.loki_worker.write_storage_directives
  backend_units                     = local.values.loki_worker.backend_units
  read_units                        = local.values.loki_worker.read_units
  write_units                       = local.values.loki_worker.write_units
}

module "mimir" {
  source = "git::https://github.com/canonical/mimir-operators//terraform"

  anti_affinity                     = local.values.anti_affinity
  base                              = local.bases.o11y
  channel                           = local.channels.mimir
  model_uuid                        = local.model_uuid
  s3_endpoint                       = var.s3_endpoint
  s3_secret_key                     = var.s3_secret_key
  s3_access_key                     = var.s3_access_key
  s3_bucket                         = var.mimir_bucket
  s3_integrator_base                = local.bases.s3_integrator
  s3_integrator_channel             = local.channels.s3_integrator
  s3_integrator_config              = local.values.s3_integrator.config
  s3_integrator_constraints         = local.values.s3_integrator.constraints
  s3_integrator_revision            = local.revisions.s3_integrator
  s3_integrator_storage_directives  = local.values.s3_integrator.storage_directives
  s3_integrator_units               = local.values.s3_integrator.units
  coordinator_config                = merge(local.values.mimir_coordinator.config, { "max_global_exemplars_per_user" = "100000" })
  coordinator_constraints           = local.values.mimir_coordinator.constraints
  coordinator_resources             = local.values.mimir_coordinator.resources
  coordinator_revision              = local.revisions.mimir_coordinator
  coordinator_storage_directives    = local.values.mimir_coordinator.storage_directives
  coordinator_units                 = local.values.mimir_coordinator.units
  backend_config                    = local.values.mimir_worker.backend_config
  read_config                       = local.values.mimir_worker.read_config
  write_config                      = local.values.mimir_worker.write_config
  worker_constraints                = local.values.mimir_worker.constraints
  worker_revision                   = local.revisions.mimir_worker
  worker_resources                  = local.values.mimir_worker.resources
  backend_worker_storage_directives = local.values.mimir_worker.backend_storage_directives
  read_worker_storage_directives    = local.values.mimir_worker.read_storage_directives
  write_worker_storage_directives   = local.values.mimir_worker.write_storage_directives
  backend_units                     = local.values.mimir_worker.backend_units
  read_units                        = local.values.mimir_worker.read_units
  write_units                       = local.values.mimir_worker.write_units
}

module "opentelemetry_collector" {
  source = "git::https://github.com/canonical/opentelemetry-collector-k8s-operator//terraform"

  app_name           = local.values.opentelemetry_collector.app_name
  base               = local.bases.o11y
  channel            = local.channels.otelcol
  config             = local.values.opentelemetry_collector.config
  constraints        = local.values.opentelemetry_collector.constraints
  model_uuid         = local.model_uuid
  resources          = local.values.opentelemetry_collector.resources
  revision           = local.revisions.otelcol
  storage_directives = local.values.opentelemetry_collector.storage_directives
  units              = local.values.opentelemetry_collector.units
}

module "ssc" {
  source = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  count  = local.values.internal_tls ? 1 : 0

  app_name    = local.values.ssc.app_name
  base        = local.bases.ssc
  channel     = local.channels.ssc
  config      = local.values.ssc.config
  constraints = local.values.ssc.constraints
  model_uuid  = local.model_uuid
  revision    = local.revisions.ssc
  units       = local.values.ssc.units
}

module "tempo" {
  source = "git::https://github.com/canonical/tempo-operators//terraform"

  anti_affinity                               = local.values.anti_affinity
  base                                        = local.bases.o11y
  channel                                     = local.channels.tempo
  model_uuid                                  = local.model_uuid
  s3_endpoint                                 = var.s3_endpoint
  s3_access_key                               = var.s3_access_key
  s3_secret_key                               = var.s3_secret_key
  s3_bucket                                   = var.tempo_bucket
  s3_integrator_base                          = local.bases.s3_integrator
  s3_integrator_channel                       = local.channels.s3_integrator
  s3_integrator_config                        = local.values.s3_integrator.config
  s3_integrator_constraints                   = local.values.s3_integrator.constraints
  s3_integrator_revision                      = local.revisions.s3_integrator
  s3_integrator_storage_directives            = local.values.s3_integrator.storage_directives
  s3_integrator_units                         = local.values.s3_integrator.units
  coordinator_config                          = local.values.tempo_coordinator.config
  coordinator_constraints                     = local.values.tempo_coordinator.constraints
  coordinator_resources                       = local.values.tempo_coordinator.resources
  coordinator_revision                        = local.revisions.tempo_coordinator
  coordinator_storage_directives              = local.values.tempo_coordinator.storage_directives
  coordinator_units                           = local.values.tempo_coordinator.units
  querier_config                              = local.values.tempo_worker.querier_config
  query_frontend_config                       = local.values.tempo_worker.query_frontend_config
  ingester_config                             = local.values.tempo_worker.ingester_config
  distributor_config                          = local.values.tempo_worker.distributor_config
  compactor_config                            = local.values.tempo_worker.compactor_config
  metrics_generator_config                    = local.values.tempo_worker.metrics_generator_config
  worker_constraints                          = local.values.tempo_worker.constraints
  worker_resources                            = local.values.tempo_worker.resources
  worker_revision                             = local.revisions.tempo_worker
  compactor_worker_storage_directives         = local.values.tempo_worker.compactor_worker_storage_directives
  distributor_worker_storage_directives       = local.values.tempo_worker.distributor_worker_storage_directives
  ingester_worker_storage_directives          = local.values.tempo_worker.ingester_worker_storage_directives
  metrics_generator_worker_storage_directives = local.values.tempo_worker.metrics_generator_worker_storage_directives
  querier_worker_storage_directives           = local.values.tempo_worker.querier_worker_storage_directives
  query_frontend_worker_storage_directives    = local.values.tempo_worker.query_frontend_worker_storage_directives
  compactor_units                             = local.values.tempo_worker.compactor_units
  distributor_units                           = local.values.tempo_worker.distributor_units
  ingester_units                              = local.values.tempo_worker.ingester_units
  metrics_generator_units                     = local.values.tempo_worker.metrics_generator_units
  querier_units                               = local.values.tempo_worker.querier_units
  query_frontend_units                        = local.values.tempo_worker.query_frontend_units
}

module "traefik" {
  source = "git::https://github.com/canonical/traefik-k8s-operator//terraform"
  count  = local.traefik_enabled ? 1 : 0

  app_name           = local.values.traefik.app_name
  base               = local.bases.traefik
  channel            = local.channels.traefik
  config             = var.cloud == "aws" ? { "loadbalancer_annotations" = "service.beta.kubernetes.io/aws-load-balancer-scheme=internet-facing" } : local.values.traefik.config
  constraints        = local.values.traefik.constraints
  model_uuid         = local.model_uuid
  resources          = local.values.traefik.resources
  revision           = local.revisions.traefik
  storage_directives = local.values.traefik.storage_directives
  units              = local.values.traefik.units
}

module "alertmanager" {
  source = "git::https://github.com/canonical/alertmanager-k8s-operator//terraform?ref=tf-0.31.1"

  app_name           = var.alertmanager.app_name
  base               = local.bases.o11y
  channel            = local.channels.alertmanager
  config             = var.alertmanager.config
  constraints        = var.alertmanager.constraints
  model_uuid         = local.model_uuid
  resources          = var.alertmanager.resources
  revision           = local.revisions.alertmanager
  storage_directives = var.alertmanager.storage_directives
  units              = var.alertmanager.units
}

module "catalogue" {
  source = "git::https://github.com/canonical/catalogue-k8s-operator//terraform?ref=tf-3.0.1"

  app_name           = var.catalogue.app_name
  base               = local.bases.o11y
  channel            = local.channels.catalogue
  config             = var.catalogue.config
  constraints        = var.catalogue.constraints
  model_uuid         = local.model_uuid
  resources          = var.catalogue.resources
  revision           = local.revisions.catalogue
  storage_directives = var.catalogue.storage_directives
  units              = var.catalogue.units
}

module "grafana" {
  source = "git::https://github.com/canonical/grafana-k8s-operator//terraform?ref=tf-12.4.1"

  app_name           = var.grafana.app_name
  base               = local.bases.o11y
  channel            = local.channels.grafana
  config             = var.grafana.config
  constraints        = var.grafana.constraints
  model_uuid         = local.model_uuid
  resources          = var.grafana.resources
  revision           = local.revisions.grafana
  storage_directives = var.grafana.storage_directives
  units              = var.grafana.units
  replace_triggers   = [terraform_data.grafana_litestream_resource.id]
}

module "loki" {
  source = "git::https://github.com/canonical/loki-operators//terraform?ref=tf-3.7.1"

  anti_affinity                     = var.anti_affinity
  base                              = local.bases.o11y
  channel                           = local.channels.loki
  model_uuid                        = local.model_uuid
  s3_endpoint                       = var.s3_endpoint
  s3_secret_key                     = var.s3_secret_key
  s3_access_key                     = var.s3_access_key
  s3_bucket                         = var.loki_bucket
  s3_integrator_base                = local.bases.s3_integrator
  s3_integrator_channel             = local.channels.s3_integrator
  s3_integrator_config              = var.s3_integrator.config
  s3_integrator_constraints         = var.s3_integrator.constraints
  s3_integrator_revision            = local.revisions.s3_integrator
  s3_integrator_storage_directives  = var.s3_integrator.storage_directives
  s3_integrator_units               = var.s3_integrator.units
  coordinator_config                = var.loki_coordinator.config
  coordinator_constraints           = var.loki_coordinator.constraints
  coordinator_resources             = var.loki_coordinator.resources
  coordinator_revision              = local.revisions.loki_coordinator
  coordinator_storage_directives    = var.loki_coordinator.storage_directives
  coordinator_units                 = var.loki_coordinator.units
  backend_config                    = var.loki_worker.backend_config
  read_config                       = var.loki_worker.read_config
  write_config                      = var.loki_worker.write_config
  worker_constraints                = var.loki_worker.constraints
  worker_resources                  = var.loki_worker.resources
  worker_revision                   = local.revisions.loki_worker
  backend_worker_storage_directives = var.loki_worker.backend_storage_directives
  read_worker_storage_directives    = var.loki_worker.read_storage_directives
  write_worker_storage_directives   = var.loki_worker.write_storage_directives
  backend_units                     = var.loki_worker.backend_units
  read_units                        = var.loki_worker.read_units
  write_units                       = var.loki_worker.write_units
}

module "mimir" {
  source = "git::https://github.com/canonical/mimir-operators//terraform?ref=tf-2.17.0"

  anti_affinity                     = var.anti_affinity
  base                              = local.bases.o11y
  channel                           = local.channels.mimir
  model_uuid                        = local.model_uuid
  s3_endpoint                       = var.s3_endpoint
  s3_secret_key                     = var.s3_secret_key
  s3_access_key                     = var.s3_access_key
  s3_bucket                         = var.mimir_bucket
  s3_integrator_base                = local.bases.s3_integrator
  s3_integrator_channel             = local.channels.s3_integrator
  s3_integrator_config              = var.s3_integrator.config
  s3_integrator_constraints         = var.s3_integrator.constraints
  s3_integrator_revision            = local.revisions.s3_integrator
  s3_integrator_storage_directives  = var.s3_integrator.storage_directives
  s3_integrator_units               = var.s3_integrator.units
  coordinator_config                = { "max_global_exemplars_per_user" = "100000" }
  coordinator_constraints           = var.mimir_coordinator.constraints
  coordinator_resources             = var.mimir_coordinator.resources
  coordinator_revision              = local.revisions.mimir_coordinator
  coordinator_storage_directives    = var.mimir_coordinator.storage_directives
  coordinator_units                 = var.mimir_coordinator.units
  backend_config                    = var.mimir_worker.backend_config
  read_config                       = var.mimir_worker.read_config
  write_config                      = var.mimir_worker.write_config
  worker_constraints                = var.mimir_worker.constraints
  worker_revision                   = local.revisions.mimir_worker
  worker_resources                  = var.mimir_worker.resources
  backend_worker_storage_directives = var.mimir_worker.backend_storage_directives
  read_worker_storage_directives    = var.mimir_worker.read_storage_directives
  write_worker_storage_directives   = var.mimir_worker.write_storage_directives
  backend_units                     = var.mimir_worker.backend_units
  read_units                        = var.mimir_worker.read_units
  write_units                       = var.mimir_worker.write_units
}

module "opentelemetry_collector" {
  source = "git::https://github.com/canonical/opentelemetry-collector-k8s-operator//terraform?ref=tf-0.130.1"

  app_name           = var.opentelemetry_collector.app_name
  base               = local.bases.o11y
  channel            = local.channels.otelcol
  config             = var.opentelemetry_collector.config
  constraints        = var.opentelemetry_collector.constraints
  model_uuid         = local.model_uuid
  resources          = var.opentelemetry_collector.resources
  revision           = local.revisions.otelcol
  storage_directives = var.opentelemetry_collector.storage_directives
  units              = var.opentelemetry_collector.units
}

module "ssc" {
  source = "git::https://github.com/canonical/self-signed-certificates-operator//terraform?ref=rev653"
  count  = var.internal_tls ? 1 : 0

  app_name    = var.ssc.app_name
  base        = local.bases.ssc
  channel     = local.channels.ssc
  config      = var.ssc.config
  constraints = var.ssc.constraints
  model_uuid  = local.model_uuid
  revision    = local.revisions.ssc
  units       = var.ssc.units
}

module "tempo" {
  source = "git::https://github.com/canonical/tempo-operators//terraform?ref=tf-2.10.0"

  anti_affinity                               = var.anti_affinity
  base                                        = local.bases.o11y
  channel                                     = local.channels.tempo
  model_uuid                                  = local.model_uuid
  s3_endpoint                                 = var.s3_endpoint
  s3_access_key                               = var.s3_access_key
  s3_secret_key                               = var.s3_secret_key
  s3_bucket                                   = var.tempo_bucket
  s3_integrator_base                          = local.bases.s3_integrator
  s3_integrator_channel                       = local.channels.s3_integrator
  s3_integrator_config                        = var.s3_integrator.config
  s3_integrator_constraints                   = var.s3_integrator.constraints
  s3_integrator_revision                      = local.revisions.s3_integrator
  s3_integrator_storage_directives            = var.s3_integrator.storage_directives
  s3_integrator_units                         = var.s3_integrator.units
  coordinator_config                          = var.tempo_coordinator.config
  coordinator_constraints                     = var.tempo_coordinator.constraints
  coordinator_resources                       = var.tempo_coordinator.resources
  coordinator_revision                        = local.revisions.tempo_coordinator
  coordinator_storage_directives              = var.tempo_coordinator.storage_directives
  coordinator_units                           = var.tempo_coordinator.units
  querier_config                              = var.tempo_worker.querier_config
  query_frontend_config                       = var.tempo_worker.query_frontend_config
  ingester_config                             = var.tempo_worker.ingester_config
  distributor_config                          = var.tempo_worker.distributor_config
  compactor_config                            = var.tempo_worker.compactor_config
  metrics_generator_config                    = var.tempo_worker.metrics_generator_config
  worker_constraints                          = var.tempo_worker.constraints
  worker_resources                            = var.tempo_worker.resources
  worker_revision                             = local.revisions.tempo_worker
  compactor_worker_storage_directives         = var.tempo_worker.compactor_worker_storage_directives
  distributor_worker_storage_directives       = var.tempo_worker.distributor_worker_storage_directives
  ingester_worker_storage_directives          = var.tempo_worker.ingester_worker_storage_directives
  metrics_generator_worker_storage_directives = var.tempo_worker.metrics_generator_worker_storage_directives
  querier_worker_storage_directives           = var.tempo_worker.querier_worker_storage_directives
  query_frontend_worker_storage_directives    = var.tempo_worker.query_frontend_worker_storage_directives
  compactor_units                             = var.tempo_worker.compactor_units
  distributor_units                           = var.tempo_worker.distributor_units
  ingester_units                              = var.tempo_worker.ingester_units
  metrics_generator_units                     = var.tempo_worker.metrics_generator_units
  querier_units                               = var.tempo_worker.querier_units
  query_frontend_units                        = var.tempo_worker.query_frontend_units
}

module "traefik" {
  source = "git::https://github.com/canonical/traefik-k8s-operator//terraform?ref=traefik-k8s-rev345"
  count  = local.traefik_enabled ? 1 : 0

  app_name = var.traefik.app_name
  # FIXME: Once Traefik TF module supports a base var, add it here
  # base               = local.bases.traefik
  channel            = local.channels.traefik
  config             = var.cloud == "aws" ? { "loadbalancer_annotations" = "service.beta.kubernetes.io/aws-load-balancer-scheme=internet-facing" } : var.traefik.config
  constraints        = var.traefik.constraints
  model_uuid         = local.model_uuid
  resources          = var.traefik.resources
  revision           = local.revisions.traefik
  storage_directives = var.traefik.storage_directives
  units              = var.traefik.units
}

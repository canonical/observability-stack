module "alertmanager" {
  source             = "git::https://github.com/canonical/alertmanager-k8s-operator//terraform"
  app_name           = var.alertmanager.app_name
  channel            = var.channel
  config             = var.alertmanager.config
  constraints        = var.alertmanager.constraints
  model              = var.model
  revision           = var.alertmanager.revision
  storage_directives = var.alertmanager.storage_directives
  units              = var.alertmanager.units
}

module "catalogue" {
  source             = "git::https://github.com/canonical/catalogue-k8s-operator//terraform"
  app_name           = var.catalogue.app_name
  channel            = var.channel
  config             = var.catalogue.config
  constraints        = var.catalogue.constraints
  model              = var.model
  revision           = var.catalogue.revision
  storage_directives = var.catalogue.storage_directives
  units              = var.catalogue.units
}

module "grafana" {
  source             = "git::https://github.com/canonical/grafana-k8s-operator//terraform"
  app_name           = var.grafana.app_name
  channel            = var.channel
  config             = var.grafana.config
  constraints        = var.grafana.constraints
  model              = var.model
  revision           = var.grafana.revision
  storage_directives = var.grafana.storage_directives
  units              = var.grafana.units
}

module "loki" {
  source                           = "git::https://github.com/canonical/observability-stack//terraform/loki"
  anti_affinity                    = var.anti_affinity
  channel                          = var.channel
  model                            = var.model
  s3_endpoint                      = var.s3_endpoint
  s3_secret_key                    = var.s3_secret_key
  s3_access_key                    = var.s3_access_key
  s3_bucket                        = var.loki_bucket
  s3_integrator_channel            = var.s3_integrator.channel
  s3_integrator_config             = var.s3_integrator.config
  s3_integrator_constraints        = var.s3_integrator.constraints
  s3_integrator_revision           = var.s3_integrator.revision
  s3_integrator_storage_directives = var.s3_integrator.storage_directives
  s3_integrator_units              = var.s3_integrator.units
  coordinator_config               = var.loki_coordinator.config
  coordinator_constraints          = var.loki_coordinator.constraints
  coordinator_revision             = var.loki_coordinator.revision
  coordinator_storage_directives   = var.loki_coordinator.storage_directives
  coordinator_units                = var.loki_coordinator.units
  backend_config                   = var.loki_worker.backend_config
  read_config                      = var.loki_worker.read_config
  write_config                     = var.loki_worker.write_config
  worker_constraints               = var.loki_worker.constraints
  worker_revision                  = var.loki_worker.revision
  worker_storage_directives        = var.loki_worker.storage_directives
  backend_units                    = var.loki_worker.backend_units
  read_units                       = var.loki_worker.read_units
  write_units                      = var.loki_worker.write_units
}

module "mimir" {
  source                           = "git::https://github.com/canonical/observability-stack//terraform/mimir"
  anti_affinity                    = var.anti_affinity
  channel                          = var.channel
  model                            = var.model
  s3_endpoint                      = var.s3_endpoint
  s3_secret_key                    = var.s3_secret_key
  s3_access_key                    = var.s3_access_key
  s3_bucket                        = var.mimir_bucket
  s3_integrator_channel            = var.s3_integrator.channel
  s3_integrator_config             = var.s3_integrator.config
  s3_integrator_constraints        = var.s3_integrator.constraints
  s3_integrator_revision           = var.s3_integrator.revision
  s3_integrator_storage_directives = var.s3_integrator.storage_directives
  s3_integrator_units              = var.s3_integrator.units
  coordinator_config = merge(var.mimir_coordinator.config, {
    # metrics-to-traces requires exemplar storage enabled
    "max_global_exemplars_per_user" = "100000"
  })
  coordinator_constraints        = var.mimir_coordinator.constraints
  coordinator_revision           = var.mimir_coordinator.revision
  coordinator_storage_directives = var.mimir_coordinator.storage_directives
  coordinator_units              = var.mimir_coordinator.units
  backend_config                 = var.mimir_worker.backend_config
  read_config                    = var.mimir_worker.read_config
  write_config                   = var.mimir_worker.write_config
  worker_constraints             = var.mimir_worker.constraints
  worker_revision                = var.mimir_worker.revision
  worker_storage_directives      = var.mimir_worker.storage_directives
  backend_units                  = var.mimir_worker.backend_units
  read_units                     = var.mimir_worker.read_units
  write_units                    = var.mimir_worker.write_units
}

module "opentelemetry_collector" {
  source             = "git::https://github.com/canonical/opentelemetry-collector-k8s-operator//terraform"
  app_name           = var.opentelemetry_collector.app_name
  channel            = var.channel
  config             = var.opentelemetry_collector.config
  constraints        = var.opentelemetry_collector.constraints
  model              = var.model
  revision           = var.opentelemetry_collector.revision
  storage_directives = var.opentelemetry_collector.storage_directives
  units              = var.opentelemetry_collector.units
}

module "ssc" {
  count       = var.internal_tls ? 1 : 0
  source      = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  app_name    = var.ssc.app_name
  channel     = var.ssc.channel
  config      = var.ssc.config
  constraints = var.ssc.constraints
  model       = var.model
  revision    = var.ssc.revision
  units       = var.ssc.units
}

module "tempo" {
  source                           = "git::https://github.com/canonical/tempo-operators//terraform"
  anti_affinity                    = var.anti_affinity
  channel                          = var.channel
  model                            = var.model
  s3_endpoint                      = var.s3_endpoint
  s3_access_key                    = var.s3_access_key
  s3_secret_key                    = var.s3_secret_key
  s3_bucket                        = var.tempo_bucket
  s3_integrator_channel            = var.s3_integrator.channel
  s3_integrator_config             = var.s3_integrator.config
  s3_integrator_constraints        = var.s3_integrator.constraints
  s3_integrator_revision           = var.s3_integrator.revision
  s3_integrator_storage_directives = var.s3_integrator.storage_directives
  s3_integrator_units              = var.s3_integrator.units
  coordinator_config               = var.tempo_coordinator.config
  coordinator_constraints          = var.tempo_coordinator.constraints
  coordinator_revision             = var.tempo_coordinator.revision
  coordinator_storage_directives   = var.tempo_coordinator.storage_directives
  coordinator_units                = var.tempo_coordinator.units
  querier_config                   = var.tempo_worker.querier_config
  query_frontend_config            = var.tempo_worker.query_frontend_config
  ingester_config                  = var.tempo_worker.ingester_config
  distributor_config               = var.tempo_worker.distributor_config
  compactor_config                 = var.tempo_worker.compactor_config
  metrics_generator_config         = var.tempo_worker.metrics_generator_config
  worker_constraints               = var.tempo_worker.constraints
  worker_revision                  = var.tempo_worker.revision
  worker_storage_directives        = var.tempo_worker.storage_directives
  compactor_units                  = var.tempo_worker.compactor_units
  distributor_units                = var.tempo_worker.distributor_units
  ingester_units                   = var.tempo_worker.ingester_units
  metrics_generator_units          = var.tempo_worker.metrics_generator_units
  querier_units                    = var.tempo_worker.querier_units
  query_frontend_units             = var.tempo_worker.query_frontend_units
}

module "traefik" {
  source             = "git::https://github.com/canonical/traefik-k8s-operator//terraform"
  app_name           = var.traefik.app_name
  channel            = var.traefik.channel
  config             = var.cloud == "aws" ? { "loadbalancer_annotations" = "service.beta.kubernetes.io/aws-load-balancer-scheme=internet-facing" } : var.traefik.config
  constraints        = var.traefik.constraints
  model              = var.model
  revision           = var.traefik.revision
  storage_directives = var.traefik.storage_directives
  units              = var.traefik.units
}

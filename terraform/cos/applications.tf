# -------------- # Applications --------------

module "alertmanager" {
  source             = "git::https://github.com/canonical/alertmanager-k8s-operator//terraform"
  app_name           = "alertmanager"
  channel            = var.channel
  config             = var.alertmanager_config
  constraints        = var.alertmanager_constraints
  model              = var.model
  revision           = var.alertmanager_revision
  storage_directives = var.alertmanager_storage_directives
}

module "catalogue" {
  source             = "git::https://github.com/canonical/catalogue-k8s-operator//terraform"
  app_name           = "catalogue"
  channel            = var.channel
  config             = var.catalogue_config
  constraints        = var.catalogue_constraints
  model              = var.model
  revision           = var.catalogue_revision
  storage_directives = var.catalogue_storage_directives
}

module "grafana" {
  source             = "git::https://github.com/canonical/grafana-k8s-operator//terraform"
  app_name           = "grafana"
  channel            = var.channel
  config             = var.grafana_config
  constraints        = var.grafana_constraints
  model              = var.model
  revision           = var.grafana_revision
  storage_directives = var.grafana_storage_directives
}

module "grafana_agent" {
  source             = "git::https://github.com/canonical/grafana-agent-k8s-operator//terraform"
  app_name           = "grafana-agent"
  channel            = var.channel
  config             = var.grafana_agent_config
  constraints        = var.grafana_agent_constraints
  model              = var.model
  revision           = var.grafana_agent_revision
  storage_directives = var.grafana_agent_storage_directives
}

module "loki" {
  # source                 = "git::https://github.com/canonical/observability-stack//terraform/loki"
  source                         = "../loki"  # FIXME
  anti_affinity                  = var.anti_affinity
  channel                        = var.channel
  model                          = var.model
  s3_integrator_channel          = var.s3_integrator_channel
  s3_integrator_revision         = var.s3_integrator_revision
  s3_endpoint                    = var.s3_endpoint
  s3_secret_key                  = var.s3_secret_key
  s3_access_key                  = var.s3_access_key
  s3_bucket                      = var.loki_bucket
  coordinator_config             = var.loki_coordinator_config
  coordinator_constraints        = var.loki_coordinator_constraints
  coordinator_revision           = var.loki_coordinator_revision
  coordinator_storage_directives = var.loki_coordinator_storage_directives
  coordinator_units              = var.loki_coordinator_units
  worker_config                  = var.loki_worker_config
  worker_constraints             = var.loki_worker_constraints
  worker_revision                = var.loki_worker_revision
  worker_storage_directives      = var.loki_worker_storage_directives
  backend_units                  = var.loki_backend_units
  read_units                     = var.loki_read_units
  write_units                    = var.loki_write_units
}

module "mimir" {
  # source                 = "git::https://github.com/canonical/observability-stack//terraform/mimir"
  source                         = "../mimir"  # FIXME
  anti_affinity                  = var.anti_affinity
  channel                        = var.channel
  model                          = var.model
  s3_integrator_channel          = var.s3_integrator_channel
  s3_integrator_revision         = var.s3_integrator_revision
  s3_endpoint                    = var.s3_endpoint
  s3_secret_key                  = var.s3_secret_key
  s3_access_key                  = var.s3_access_key
  s3_bucket                      = var.mimir_bucket
  coordinator_config             = var.mimir_coordinator_config
  coordinator_constraints        = var.mimir_coordinator_constraints
  coordinator_revision           = var.mimir_coordinator_revision
  coordinator_storage_directives = var.mimir_coordinator_storage_directives
  coordinator_units              = var.mimir_coordinator_units
  worker_config                  = var.mimir_worker_config
  worker_constraints             = var.mimir_worker_constraints
  worker_revision                = var.mimir_worker_revision
  worker_storage_directives      = var.mimir_worker_storage_directives
  backend_units                  = var.mimir_backend_units
  read_units                     = var.mimir_read_units
  write_units                    = var.mimir_write_units
}

module "ssc" {
  count       = var.internal_tls ? 1 : 0
  source      = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  channel     = var.ssc_channel
  config      = var.ssc_config
  constraints = var.ssc_constraints
  model       = var.model
  revision    = var.ssc_revision
}

module "tempo" {
  source                  = "git::https://github.com/canonical/observability-stack//terraform/tempo"
  source                         = "../tempo"  # FIXME
  anti_affinity                  = var.anti_affinity
  channel                        = var.channel
  model                          = var.model
  s3_integrator_channel          = var.s3_integrator_channel
  s3_integrator_revision         = var.s3_integrator_revision
  s3_endpoint                    = var.s3_endpoint
  s3_access_key                  = var.s3_access_key
  s3_secret_key                  = var.s3_secret_key
  s3_bucket                      = var.tempo_bucket
  coordinator_config             = var.tempo_coordinator_config
  coordinator_constraints        = var.tempo_coordinator_constraints
  coordinator_revision           = var.tempo_coordinator_revision
  coordinator_storage_directives = var.tempo_coordinator_storage_directives
  coordinator_units              = var.tempo_coordinator_units
  worker_config                  = var.tempo_worker_config
  worker_constraints             = var.tempo_worker_constraints
  worker_revision                = var.tempo_worker_revision
  worker_storage_directives      = var.tempo_worker_storage_directives
  compactor_units                = var.tempo_compactor_units
  distributor_units              = var.tempo_distributor_units
  ingester_units                 = var.tempo_ingester_units
  metrics_generator_units        = var.tempo_metrics_generator_units
  querier_units                  = var.tempo_querier_units
  query_frontend_units           = var.tempo_query_frontend_units
}

module "traefik" {
  source             = "git::https://github.com/canonical/traefik-k8s-operator//terraform"
  app_name           = "traefik"
  channel            = var.traefik_channel
  config             = var.cloud == "aws" ? { "loadbalancer_annotations" = "service.beta.kubernetes.io/aws-load-balancer-scheme=internet-facing" } : var.traefik_config
  constraints        = var.traefik_constraints
  model              = var.model
  revision           = var.traefik_revision
  storage_directives = var.traefik_storage_directives
}

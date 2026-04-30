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

# Monolithic: single all-in-one worker
module "loki_worker" {
  count      = var.topology == "monolithic" ? 1 : 0
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

# Distributed: separate backend, read, and write workers
module "loki_worker_backend" {
  count      = var.topology == "distributed" ? 1 : 0
  source     = "git::https://github.com/canonical/loki-operators//worker/terraform"
  depends_on = [module.loki_coordinator]

  app_name           = "${var.loki_worker.app_name}-backend"
  channel            = local.channels.loki
  config             = merge({ "role-backend" = "true" }, var.loki_worker.backend_config)
  constraints        = var.loki_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.loki_worker
  storage_directives = var.loki_worker.backend_storage_directives
  units              = var.loki_worker.backend_units
}

module "loki_worker_read" {
  count      = var.topology == "distributed" ? 1 : 0
  source     = "git::https://github.com/canonical/loki-operators//worker/terraform"
  depends_on = [module.loki_coordinator]

  app_name           = "${var.loki_worker.app_name}-read"
  channel            = local.channels.loki
  config             = merge({ "role-read" = "true" }, var.loki_worker.read_config)
  constraints        = var.loki_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.loki_worker
  storage_directives = var.loki_worker.read_storage_directives
  units              = var.loki_worker.read_units
}

module "loki_worker_write" {
  count      = var.topology == "distributed" ? 1 : 0
  source     = "git::https://github.com/canonical/loki-operators//worker/terraform"
  depends_on = [module.loki_coordinator]

  app_name           = "${var.loki_worker.app_name}-write"
  channel            = local.channels.loki
  config             = merge({ "role-write" = "true" }, var.loki_worker.write_config)
  constraints        = var.loki_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.loki_worker
  storage_directives = var.loki_worker.write_storage_directives
  units              = var.loki_worker.write_units
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

# Monolithic: single all-in-one worker
module "mimir_worker" {
  count      = var.topology == "monolithic" ? 1 : 0
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

# Distributed: separate backend, read, and write workers
module "mimir_worker_backend" {
  count      = var.topology == "distributed" ? 1 : 0
  source     = "git::https://github.com/canonical/mimir-operators//worker/terraform"
  depends_on = [module.mimir_coordinator]

  app_name           = "${var.mimir_worker.app_name}-backend"
  channel            = local.channels.mimir
  config             = merge({ "role-backend" = "true" }, var.mimir_worker.backend_config)
  constraints        = var.mimir_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.mimir_worker
  storage_directives = var.mimir_worker.backend_storage_directives
  units              = var.mimir_worker.backend_units
}

module "mimir_worker_read" {
  count      = var.topology == "distributed" ? 1 : 0
  source     = "git::https://github.com/canonical/mimir-operators//worker/terraform"
  depends_on = [module.mimir_coordinator]

  app_name           = "${var.mimir_worker.app_name}-read"
  channel            = local.channels.mimir
  config             = merge({ "role-read" = "true" }, var.mimir_worker.read_config)
  constraints        = var.mimir_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.mimir_worker
  storage_directives = var.mimir_worker.read_storage_directives
  units              = var.mimir_worker.read_units
}

module "mimir_worker_write" {
  count      = var.topology == "distributed" ? 1 : 0
  source     = "git::https://github.com/canonical/mimir-operators//worker/terraform"
  depends_on = [module.mimir_coordinator]

  app_name           = "${var.mimir_worker.app_name}-write"
  channel            = local.channels.mimir
  config             = merge({ "role-write" = "true" }, var.mimir_worker.write_config)
  constraints        = var.mimir_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.mimir_worker
  storage_directives = var.mimir_worker.write_storage_directives
  units              = var.mimir_worker.write_units
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

# -------------- # SeaweedFS (storage_backend = "seaweedfs") --------------

module "seaweedfs" {
  count              = var.storage_backend == "seaweedfs" ? 1 : 0
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

# -------------- # S3-integrators (storage_backend = "s3") --------------

resource "juju_secret" "loki_s3_credentials" {
  count      = var.storage_backend == "s3" ? 1 : 0
  model_uuid = var.model_uuid
  name       = "loki-s3-credentials"
  value = {
    access-key = var.s3_access_key
    secret-key = var.s3_secret_key
  }
  info = "S3 credentials for Loki"
}

resource "juju_access_secret" "loki_s3_credentials_access" {
  count        = var.storage_backend == "s3" ? 1 : 0
  model_uuid   = var.model_uuid
  applications = [juju_application.s3_integrator_loki[0].name]
  secret_id    = juju_secret.loki_s3_credentials[0].secret_id
}

# TODO: Replace with a remote terraform module once the s3-integrator charm exposes one.
resource "juju_application" "s3_integrator_loki" {
  count = var.storage_backend == "s3" ? 1 : 0
  config = merge({
    endpoint    = var.s3_endpoint
    bucket      = var.loki_bucket
    credentials = "secret:${juju_secret.loki_s3_credentials[0].secret_id}"
  }, var.s3_integrator.config)
  constraints        = var.s3_integrator.constraints
  model_uuid         = var.model_uuid
  name               = "${var.loki_coordinator.app_name}-s3-integrator"
  storage_directives = var.s3_integrator.storage_directives
  trust              = true
  units              = var.s3_integrator.units

  charm {
    name     = "s3-integrator"
    channel  = local.channels.s3_integrator
    revision = local.revisions.s3_integrator
  }
}

resource "juju_secret" "mimir_s3_credentials" {
  count      = var.storage_backend == "s3" ? 1 : 0
  model_uuid = var.model_uuid
  name       = "mimir-s3-credentials"
  value = {
    access-key = var.s3_access_key
    secret-key = var.s3_secret_key
  }
  info = "S3 credentials for Mimir"
}

resource "juju_access_secret" "mimir_s3_credentials_access" {
  count        = var.storage_backend == "s3" ? 1 : 0
  model_uuid   = var.model_uuid
  applications = [juju_application.s3_integrator_mimir[0].name]
  secret_id    = juju_secret.mimir_s3_credentials[0].secret_id
}

resource "juju_application" "s3_integrator_mimir" {
  count = var.storage_backend == "s3" ? 1 : 0
  config = merge({
    endpoint    = var.s3_endpoint
    bucket      = var.mimir_bucket
    credentials = "secret:${juju_secret.mimir_s3_credentials[0].secret_id}"
  }, var.s3_integrator.config)
  constraints        = var.s3_integrator.constraints
  model_uuid         = var.model_uuid
  name               = "${var.mimir_coordinator.app_name}-s3-integrator"
  storage_directives = var.s3_integrator.storage_directives
  trust              = true
  units              = var.s3_integrator.units

  charm {
    name     = "s3-integrator"
    channel  = local.channels.s3_integrator
    revision = local.revisions.s3_integrator
  }
}

resource "juju_secret" "tempo_s3_credentials" {
  count      = var.storage_backend == "s3" ? 1 : 0
  model_uuid = var.model_uuid
  name       = "tempo-s3-credentials"
  value = {
    access-key = var.s3_access_key
    secret-key = var.s3_secret_key
  }
  info = "S3 credentials for Tempo"
}

resource "juju_access_secret" "tempo_s3_credentials_access" {
  count        = var.storage_backend == "s3" ? 1 : 0
  model_uuid   = var.model_uuid
  applications = [juju_application.s3_integrator_tempo[0].name]
  secret_id    = juju_secret.tempo_s3_credentials[0].secret_id
}

resource "juju_application" "s3_integrator_tempo" {
  count = var.storage_backend == "s3" ? 1 : 0
  config = merge({
    endpoint    = var.s3_endpoint
    bucket      = var.tempo_bucket
    credentials = "secret:${juju_secret.tempo_s3_credentials[0].secret_id}"
  }, var.s3_integrator.config)
  constraints        = var.s3_integrator.constraints
  model_uuid         = var.model_uuid
  name               = "${var.tempo_coordinator.app_name}-s3-integrator"
  storage_directives = var.s3_integrator.storage_directives
  trust              = true
  units              = var.s3_integrator.units

  charm {
    name     = "s3-integrator"
    channel  = local.channels.s3_integrator
    revision = local.revisions.s3_integrator
  }
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

# Monolithic: single all-in-one worker
module "tempo_worker" {
  count      = var.topology == "monolithic" ? 1 : 0
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

# Distributed: separate workers per role
module "tempo_worker_querier" {
  count      = var.topology == "distributed" ? 1 : 0
  source     = "git::https://github.com/canonical/tempo-operators//worker/terraform"
  depends_on = [module.tempo_coordinator]

  app_name           = "${var.tempo_worker.app_name}-querier"
  channel            = local.channels.tempo
  config             = merge({ "role-all" = "false", "role-querier" = "true" }, var.tempo_worker.querier_config)
  constraints        = var.tempo_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.tempo_worker
  storage_directives = var.tempo_worker.querier_storage_directives
  units              = var.tempo_worker.querier_units
}

module "tempo_worker_query_frontend" {
  count      = var.topology == "distributed" ? 1 : 0
  source     = "git::https://github.com/canonical/tempo-operators//worker/terraform"
  depends_on = [module.tempo_coordinator]

  app_name           = "${var.tempo_worker.app_name}-query-frontend"
  channel            = local.channels.tempo
  config             = merge({ "role-all" = "false", "role-query-frontend" = "true" }, var.tempo_worker.query_frontend_config)
  constraints        = var.tempo_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.tempo_worker
  storage_directives = var.tempo_worker.query_frontend_storage_directives
  units              = var.tempo_worker.query_frontend_units
}

module "tempo_worker_ingester" {
  count      = var.topology == "distributed" ? 1 : 0
  source     = "git::https://github.com/canonical/tempo-operators//worker/terraform"
  depends_on = [module.tempo_coordinator]

  app_name           = "${var.tempo_worker.app_name}-ingester"
  channel            = local.channels.tempo
  config             = merge({ "role-all" = "false", "role-ingester" = "true" }, var.tempo_worker.ingester_config)
  constraints        = var.tempo_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.tempo_worker
  storage_directives = var.tempo_worker.ingester_storage_directives
  units              = var.tempo_worker.ingester_units
}

module "tempo_worker_distributor" {
  count      = var.topology == "distributed" ? 1 : 0
  source     = "git::https://github.com/canonical/tempo-operators//worker/terraform"
  depends_on = [module.tempo_coordinator]

  app_name           = "${var.tempo_worker.app_name}-distributor"
  channel            = local.channels.tempo
  config             = merge({ "role-all" = "false", "role-distributor" = "true" }, var.tempo_worker.distributor_config)
  constraints        = var.tempo_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.tempo_worker
  storage_directives = var.tempo_worker.distributor_storage_directives
  units              = var.tempo_worker.distributor_units
}

module "tempo_worker_compactor" {
  count      = var.topology == "distributed" ? 1 : 0
  source     = "git::https://github.com/canonical/tempo-operators//worker/terraform"
  depends_on = [module.tempo_coordinator]

  app_name           = "${var.tempo_worker.app_name}-compactor"
  channel            = local.channels.tempo
  config             = merge({ "role-all" = "false", "role-compactor" = "true" }, var.tempo_worker.compactor_config)
  constraints        = var.tempo_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.tempo_worker
  storage_directives = var.tempo_worker.compactor_storage_directives
  units              = var.tempo_worker.compactor_units
}

module "tempo_worker_metrics_generator" {
  count      = var.topology == "distributed" ? 1 : 0
  source     = "git::https://github.com/canonical/tempo-operators//worker/terraform"
  depends_on = [module.tempo_coordinator]

  app_name           = "${var.tempo_worker.app_name}-metrics-generator"
  channel            = local.channels.tempo
  config             = merge({ "role-all" = "false", "role-metrics-generator" = "true" }, var.tempo_worker.metrics_generator_config)
  constraints        = var.tempo_worker.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.tempo_worker
  storage_directives = var.tempo_worker.metrics_generator_storage_directives
  units              = var.tempo_worker.metrics_generator_units
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

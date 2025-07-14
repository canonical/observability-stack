terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.14.0"
    }
  }
}

module "cos-lite" {
  source                          = "../cos-lite"
  channel                         = "2/edge"
  model                           = "cos"
  internal_tls                    = true
  external_certificates_offer_url = null

  ssc_channel     = "1/stable"
  traefik_channel = "latest/stable"

  alertmanager_config = {}
  catalogue_config    = {}
  grafana_config      = {}
  loki_config         = {}
  prometheus_config   = {}
  ssc_config          = {}
  traefik_config      = {}

  alertmanager_constraints = "arch=amd64"
  catalogue_constraints    = "arch=amd64"
  grafana_constraints      = "arch=amd64"
  loki_constraints         = "arch=amd64"
  prometheus_constraints   = "arch=amd64"
  ssc_constraints          = "arch=amd64"
  traefik_constraints      = "arch=amd64"

  alertmanager_revision = null
  catalogue_revision    = null
  grafana_revision      = null
  loki_revision         = null
  prometheus_revision   = null
  ssc_revision          = null
  traefik_revision      = null

  alertmanager_storage_directives = {}
  catalogue_storage_directives    = {}
  grafana_storage_directives      = {}
  # loki_storage_directives         = {} # FIXME, needs tangent PR
  # prometheus_storage_directives   = {} # FIXME, needs tangent PR
  # ssc_storage_directives          = {} # FIXME, needs tangent PR
  traefik_storage_directives = {}

  alertmanager_units = 1
  catalogue_units    = 1
  grafana_units      = 1
  loki_units         = 1
  prometheus_units   = 1
  ssc_units          = 1
  traefik_units      = 1
}

module "cos" {
  source                          = "../cos"
  model                           = "cos"
  cloud                           = "self-managed"
  channel                         = "2/edge"
  ssc_channel                     = "1/stable"
  traefik_channel                 = "latest/stable"
  s3_integrator_channel           = "2/edge"
  anti_affinity                   = false
  internal_tls                    = true
  external_certificates_offer_url = null

  s3_endpoint   = "http://S3_IP:8080"
  s3_secret_key = "secret-key"
  s3_access_key = "access-key"
  loki_bucket   = "loki"
  mimir_bucket  = "mimir"
  tempo_bucket  = "tempo"

  alertmanager_config            = {}
  catalogue_config               = {}
  grafana_config                 = {}
  grafana_agent_config           = {}
  loki_coordinator_config        = {}
  loki_backend_config            = {}
  loki_read_config               = {}
  loki_write_config              = {}
  mimir_coordinator_config       = {}
  mimir_backend_config           = {}
  mimir_read_config              = {}
  mimir_write_config             = {}
  ssc_config                     = {}
  s3_integrator_config           = {}
  tempo_coordinator_config       = {}
  tempo_querier_config           = {}
  tempo_query_frontend_config    = {}
  tempo_ingester_config          = {}
  tempo_distributor_config       = {}
  tempo_compactor_config         = {}
  tempo_metrics_generator_config = {}
  traefik_config                 = {}

  alertmanager_constraints      = "arch=amd64"
  catalogue_constraints         = "arch=amd64"
  grafana_constraints           = "arch=amd64"
  grafana_agent_constraints     = "arch=amd64"
  loki_coordinator_constraints  = "arch=amd64"
  loki_worker_constraints       = "arch=amd64"
  mimir_coordinator_constraints = "arch=amd64"
  mimir_worker_constraints      = "arch=amd64"
  ssc_constraints               = "arch=amd64"
  s3_integrator_constraints     = "arch=amd64"
  tempo_coordinator_constraints = "arch=amd64"
  tempo_worker_constraints      = "arch=amd64"
  traefik_constraints           = "arch=amd64"

  alertmanager_revision      = null
  catalogue_revision         = null
  grafana_revision           = null
  grafana_agent_revision     = null
  loki_coordinator_revision  = null
  loki_worker_revision       = null
  mimir_coordinator_revision = null
  mimir_worker_revision      = null
  ssc_revision               = null
  s3_integrator_revision     = 157
  tempo_coordinator_revision = null
  tempo_worker_revision      = null
  traefik_revision           = null

  alertmanager_storage_directives      = {}
  catalogue_storage_directives         = {}
  grafana_storage_directives           = {}
  grafana_agent_storage_directives     = {}
  loki_coordinator_storage_directives  = {}
  loki_worker_storage_directives       = {}
  mimir_coordinator_storage_directives = {}
  mimir_worker_storage_directives      = {}
  # ssc_storage_directives               = {} # FIXME, needs tangent PR
  s3_integrator_storage_directives     = {}
  tempo_coordinator_storage_directives = {}
  tempo_worker_storage_directives      = {}
  traefik_storage_directives           = {}

  alertmanager_units            = 1
  catalogue_units               = 1
  grafana_units                 = 1
  grafana_agent_units           = 1
  loki_coordinator_units        = 3
  loki_backend_units            = 3
  loki_read_units               = 3
  loki_write_units              = 3
  mimir_coordinator_units       = 3
  mimir_backend_units           = 3
  mimir_read_units              = 3
  mimir_write_units             = 3
  ssc_units                     = 1
  s3_integrator_units           = 1
  tempo_coordinator_units       = 3
  tempo_compactor_units         = 3
  tempo_distributor_units       = 3
  tempo_ingester_units          = 3
  tempo_metrics_generator_units = 3
  tempo_querier_units           = 3
  tempo_query_frontend_units    = 3
  traefik_units                 = 1
}

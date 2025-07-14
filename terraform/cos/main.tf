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
  units              = var.alertmanager_units
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
  units              = var.catalogue_units
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
  units              = var.grafana_units
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
  units              = var.grafana_agent_units
}

module "loki" {
  source                           = "git::https://github.com/canonical/observability-stack//terraform/loki"
  anti_affinity                    = var.anti_affinity
  channel                          = var.channel
  model                            = var.model
  s3_integrator_channel            = var.s3_integrator_channel
  s3_integrator_config             = var.s3_integrator_config
  s3_integrator_constraints        = var.s3_integrator_constraints
  s3_integrator_revision           = var.s3_integrator_revision
  s3_integrator_storage_directives = var.s3_integrator_storage_directives
  s3_integrator_units              = var.s3_integrator_units
  s3_endpoint                      = var.s3_endpoint
  s3_secret_key                    = var.s3_secret_key
  s3_access_key                    = var.s3_access_key
  s3_bucket                        = var.loki_bucket
  coordinator_config               = var.loki_coordinator_config
  coordinator_constraints          = var.loki_coordinator_constraints
  coordinator_revision             = var.loki_coordinator_revision
  coordinator_storage_directives   = var.loki_coordinator_storage_directives
  coordinator_units                = var.loki_coordinator_units
  backend_config                   = var.loki_backend_config
  read_config                      = var.loki_read_config
  write_config                     = var.loki_write_config
  worker_constraints               = var.loki_worker_constraints
  worker_revision                  = var.loki_worker_revision
  worker_storage_directives        = var.loki_worker_storage_directives
  backend_units                    = var.loki_backend_units
  read_units                       = var.loki_read_units
  write_units                      = var.loki_write_units
}

module "mimir" {
  source                           = "git::https://github.com/canonical/observability-stack//terraform/mimir"
  anti_affinity                    = var.anti_affinity
  channel                          = var.channel
  model                            = var.model
  s3_integrator_channel            = var.s3_integrator_channel
  s3_integrator_config             = var.s3_integrator_config
  s3_integrator_constraints        = var.s3_integrator_constraints
  s3_integrator_revision           = var.s3_integrator_revision
  s3_integrator_storage_directives = var.s3_integrator_storage_directives
  s3_integrator_units              = var.s3_integrator_units
  s3_endpoint                      = var.s3_endpoint
  s3_secret_key                    = var.s3_secret_key
  s3_access_key                    = var.s3_access_key
  s3_bucket                        = var.mimir_bucket
  coordinator_config               = var.mimir_coordinator_config
  coordinator_constraints          = var.mimir_coordinator_constraints
  coordinator_revision             = var.mimir_coordinator_revision
  coordinator_storage_directives   = var.mimir_coordinator_storage_directives
  coordinator_units                = var.mimir_coordinator_units
  backend_config                   = var.mimir_backend_config
  read_config                      = var.mimir_read_config
  write_config                     = var.mimir_write_config
  worker_constraints               = var.mimir_worker_constraints
  worker_revision                  = var.mimir_worker_revision
  worker_storage_directives        = var.mimir_worker_storage_directives
  backend_units                    = var.mimir_backend_units
  read_units                       = var.mimir_read_units
  write_units                      = var.mimir_write_units
}

module "ssc" {
  count       = var.internal_tls ? 1 : 0
  source      = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  channel     = var.ssc_channel
  config      = var.ssc_config
  constraints = var.ssc_constraints
  model       = var.model
  revision    = var.ssc_revision
  # storage_directives = var.ssc_storage_directives
  units = var.ssc_units
}

module "tempo" {
  source                           = "git::https://github.com/canonical/observability-stack//terraform/tempo"
  anti_affinity                    = var.anti_affinity
  channel                          = var.channel
  model                            = var.model
  s3_integrator_channel            = var.s3_integrator_channel
  s3_integrator_config             = var.s3_integrator_config
  s3_integrator_constraints        = var.s3_integrator_constraints
  s3_integrator_revision           = var.s3_integrator_revision
  s3_integrator_storage_directives = var.s3_integrator_storage_directives
  s3_integrator_units              = var.s3_integrator_units
  s3_endpoint                      = var.s3_endpoint
  s3_access_key                    = var.s3_access_key
  s3_secret_key                    = var.s3_secret_key
  s3_bucket                        = var.tempo_bucket
  coordinator_config               = var.tempo_coordinator_config
  coordinator_constraints          = var.tempo_coordinator_constraints
  coordinator_revision             = var.tempo_coordinator_revision
  coordinator_storage_directives   = var.tempo_coordinator_storage_directives
  coordinator_units                = var.tempo_coordinator_units
  querier_config                   = var.tempo_querier_config
  query_frontend_config            = var.tempo_query_frontend_config
  ingester_config                  = var.tempo_ingester_config
  distributor_config               = var.tempo_distributor_config
  compactor_config                 = var.tempo_compactor_config
  metrics_generator_config         = var.tempo_metrics_generator_config
  worker_constraints               = var.tempo_worker_constraints
  worker_revision                  = var.tempo_worker_revision
  worker_storage_directives        = var.tempo_worker_storage_directives
  compactor_units                  = var.tempo_compactor_units
  distributor_units                = var.tempo_distributor_units
  ingester_units                   = var.tempo_ingester_units
  metrics_generator_units          = var.tempo_metrics_generator_units
  querier_units                    = var.tempo_querier_units
  query_frontend_units             = var.tempo_query_frontend_units
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
  units              = var.traefik_units
}

# -------------- # Integrations --------------

# Provided by Alertmanager

resource "juju_integration" "alertmanager_grafana_dashboards" {
  model = var.model

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.grafana_dashboard
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "mimir_alertmanager" {
  model = var.model

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.alertmanager
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.alerting
  }
}

resource "juju_integration" "loki_alertmanager" {
  model = var.model

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.alertmanager
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.alerting
  }
}

resource "juju_integration" "agent_alertmanager_metrics" {
  model = var.model

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.self_metrics_endpoint
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.metrics_endpoint
  }
}

resource "juju_integration" "grafana_source_alertmanager" {
  model = var.model

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_source
  }
}

# Provided by Mimir

resource "juju_integration" "mimir_grafana_dashboards_provider" {
  model = var.model

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.grafana_dashboards_provider
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "mimir_grafana_source" {
  model = var.model

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_source
  }
}

resource "juju_integration" "mimir_tracing_grafana_agent_tracing_provider" {
  model = var.model

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.charm_tracing
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.tracing_provider
  }
}


resource "juju_integration" "mimir_self_metrics_endpoint_grafana_agent_metrics_endpoint" {
  model = var.model

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.self_metrics_endpoint
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.metrics_endpoint
  }
}


resource "juju_integration" "mimir_logging_consumer_grafana_agent_logging_provider" {
  model = var.model

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.logging_consumer
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.logging_provider
  }
}


# Provided by Loki

resource "juju_integration" "loki_grafana_dashboards_provider" {
  model = var.model

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.grafana_dashboards_provider
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "loki_grafana_source" {
  model = var.model

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_source
  }
}

resource "juju_integration" "loki_logging_consumer_grafana_agent_logging_provider" {
  model = var.model

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.logging_consumer
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.logging_provider
  }
}

resource "juju_integration" "loki_logging_grafana_agent_logging_consumer" {
  model = var.model

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.logging
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.logging_consumer
  }
}

resource "juju_integration" "loki_tracing_grafana_agent_traicing_provider" {
  model = var.model

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.charm_tracing
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.tracing_provider
  }
}

# Provided by Tempo
resource "juju_integration" "tempo_grafana_source" {
  model = var.model

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_source
  }
}

resource "juju_integration" "tempo_tracing_grafana_agent_tracing" {
  model = var.model

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.tracing
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.tracing
  }
}

resource "juju_integration" "tempo_metrics_endpoint_grafana_agent_metrics_endpoint" {
  model = var.model

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.metrics_endpoint
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.metrics_endpoint
  }
}

resource "juju_integration" "tempo_logging_grafana_agent_logging_provider" {
  model = var.model

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.logging
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.logging_provider
  }
}

resource "juju_integration" "tempo_send_remote_write_mimir_receive_remote_write" {
  model = var.model

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.send-remote-write
  }

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.receive_remote_write
  }
}

resource "juju_integration" "tempo_grafana_dashboard_grafana_grafana_dashboard" {
  model = var.model

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.grafana_dashboard

  }
  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_dashboard
  }
}

# Provided by Catalogue

resource "juju_integration" "alertmanager_catalogue" {
  model = var.model

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.catalogue
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.catalogue
  }
}

resource "juju_integration" "grafana_catalogue" {
  model = var.model

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.catalogue
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.catalogue
  }
}

resource "juju_integration" "tempo_catalogue" {
  model = var.model

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.catalogue
  }

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.catalogue
  }
}

resource "juju_integration" "mimir_catalogue" {
  model = var.model

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.catalogue
  }

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.catalogue
  }
}

# Provided by Traefik

resource "juju_integration" "alertmanager_ingress" {
  model = var.model

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.ingress
  }
}

resource "juju_integration" "catalogue_ingress" {
  model = var.model

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress
  }

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.ingress
  }
}

resource "juju_integration" "grafana_ingress" {
  model = var.model

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.traefik_route
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.ingress
  }
}

resource "juju_integration" "mimir_ingress" {
  model = var.model

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress
  }

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.ingress
  }
}

resource "juju_integration" "loki_ingress" {
  model = var.model

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress
  }

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.ingress
  }
}

resource "juju_integration" "tempo_ingress" {
  model = var.model

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.traefik_route
  }

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.ingress
  }
}

# Grafana agent

resource "juju_integration" "agent_loki_metrics" {
  model = var.model

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.self_metrics_endpoint
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.metrics_endpoint
  }
}

resource "juju_integration" "agent_mimir_metrics" {
  model = var.model

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.receive_remote_write
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.send_remote_write
  }
}

# Provided by Grafana

resource "juju_integration" "grafana_tracing_grafana_agent_traicing_provider" {
  model = var.model

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.charm_tracing
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.tracing_provider
  }
}

# Provided by Self-Signed-Certificates

resource "juju_integration" "alertmanager_certificates" {
  count = var.internal_tls ? 1 : 0
  model = var.model

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.certificates
  }
}

resource "juju_integration" "catalogue_certificates" {
  count = var.internal_tls ? 1 : 0
  model = var.model

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
  }

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.certificates
  }
}

resource "juju_integration" "grafana_certificates" {
  count = var.internal_tls ? 1 : 0
  model = var.model

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.certificates
  }
}

resource "juju_integration" "grafana_agent_certificates" {
  count = var.internal_tls ? 1 : 0
  model = var.model

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
  }

  application {
    name     = module.grafana_agent.app_name
    endpoint = module.grafana_agent.endpoints.certificates
  }
}

resource "juju_integration" "loki_certificates" {
  count = var.internal_tls ? 1 : 0
  model = var.model

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
  }

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.certificates
  }
}

resource "juju_integration" "mimir_certificates" {
  count = var.internal_tls ? 1 : 0
  model = var.model

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
  }

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.certificates
  }
}

resource "juju_integration" "tempo_certificates" {
  count = var.internal_tls ? 1 : 0
  model = var.model

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
  }

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.certificates
  }
}

resource "juju_integration" "traefik_receive_ca_certificate" {
  count = var.internal_tls ? 1 : 0
  model = var.model

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.send-ca-cert
  }

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.receive_ca_cert
  }
}

# Provided by an external CA

resource "juju_integration" "external_traefik_certificates" {
  count = local.tls_termination ? 1 : 0
  model = var.model

  application {
    offer_url = var.external_certificates_offer_url
  }

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.certificates
  }
}

# -------------- # Offers --------------

resource "juju_offer" "alertmanager_karma_dashboard" {
  name             = "alertmanager-karma-dashboard"
  model            = var.model
  application_name = module.alertmanager.app_name
  endpoints        = ["karma-dashboard"]
}

resource "juju_offer" "grafana_dashboards" {
  name             = "grafana-dashboards"
  model            = var.model
  application_name = module.grafana.app_name
  endpoints        = ["grafana-dashboard"]
}

resource "juju_offer" "loki_logging" {
  name             = "loki-logging"
  model            = var.model
  application_name = module.loki.app_names.loki_coordinator
  endpoints        = ["logging"]
}

resource "juju_offer" "mimir_receive_remote_write" {
  name             = "mimir-receive-remote-write"
  model            = var.model
  application_name = module.mimir.app_names.mimir_coordinator
  endpoints        = ["receive-remote-write"]
}

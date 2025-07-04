# -------------- # Applications --------------

module "alertmanager" {
  source   = "git::https://github.com/canonical/alertmanager-k8s-operator//terraform"
  app_name = "alertmanager"
  model    = var.model
  channel  = var.channel
  revision = var.alertmanager_revision
}

module "catalogue" {
  source   = "git::https://github.com/canonical/catalogue-k8s-operator//terraform"
  app_name = "catalogue"
  model    = var.model
  channel  = var.channel
  revision = var.catalogue_revision
}

module "grafana" {
  source   = "git::https://github.com/canonical/grafana-k8s-operator//terraform"
  app_name = "grafana"
  model    = var.model
  channel  = var.channel
  revision = var.grafana_revision
}

module "grafana_agent" {
  source   = "git::https://github.com/canonical/grafana-agent-k8s-operator//terraform"
  app_name = "grafana-agent"
  model    = var.model
  channel  = var.channel
  revision = var.grafana_agent_revision
}

module "loki" {
  source                 = "git::https://github.com/canonical/observability-stack//terraform/loki"
  model                  = var.model
  channel                = var.channel
  s3_integrator_channel  = var.s3_integrator_channel
  s3_integrator_revision = var.s3_integrator_revision
  coordinator_revision   = var.loki_coordinator_revision
  worker_revision        = var.loki_worker_revision
  coordinator_units      = var.loki_coordinator_units
  backend_units          = var.loki_backend_units
  read_units             = var.loki_read_units
  write_units            = var.loki_write_units
  s3_bucket              = var.loki_bucket
  s3_endpoint            = var.s3_endpoint
  s3_secret_key          = var.s3_secret_key
  s3_access_key          = var.s3_access_key
  anti_affinity          = var.anti_affinity
}

module "mimir" {
  source                 = "git::https://github.com/canonical/observability-stack//terraform/mimir"
  model                  = var.model
  channel                = var.channel
  s3_integrator_channel  = var.s3_integrator_channel
  s3_integrator_revision = var.s3_integrator_revision
  coordinator_revision   = var.mimir_coordinator_revision
  worker_revision        = var.mimir_worker_revision
  coordinator_units      = var.mimir_coordinator_units
  backend_units          = var.mimir_backend_units
  read_units             = var.mimir_read_units
  write_units            = var.mimir_write_units
  s3_bucket              = var.mimir_bucket
  s3_endpoint            = var.s3_endpoint
  s3_secret_key          = var.s3_secret_key
  s3_access_key          = var.s3_access_key
  anti_affinity          = var.anti_affinity
}

module "ssc" {
  count    = var.use_tls ? 1 : 0
  source   = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  model    = var.model
  channel  = var.ssc_channel
  revision = var.ssc_revision
}

module "tempo" {
  source                  = "git::https://github.com/canonical/observability-stack//terraform/tempo"
  model                   = var.model
  channel                 = var.channel
  s3_integrator_channel   = var.s3_integrator_channel
  s3_integrator_revision  = var.s3_integrator_revision
  coordinator_revision    = var.tempo_coordinator_revision
  worker_revision         = var.tempo_worker_revision
  coordinator_units       = var.tempo_coordinator_units
  compactor_units         = var.tempo_compactor_units
  distributor_units       = var.tempo_distributor_units
  ingester_units          = var.tempo_ingester_units
  metrics_generator_units = var.tempo_metrics_generator_units
  querier_units           = var.tempo_querier_units
  query_frontend_units    = var.tempo_query_frontend_units
  s3_bucket               = var.tempo_bucket
  s3_endpoint             = var.s3_endpoint
  s3_access_key           = var.s3_access_key
  s3_secret_key           = var.s3_secret_key
  anti_affinity           = var.anti_affinity
}

module "traefik" {
  source   = "git::https://github.com/canonical/traefik-k8s-operator//terraform"
  app_name = "traefik"
  model    = var.model
  channel  = var.traefik_channel
  config   = var.cloud == "aws" ? { "loadbalancer_annotations" = "service.beta.kubernetes.io/aws-load-balancer-scheme=internet-facing" } : {}
  revision = var.traefik_revision
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
  count = var.use_tls ? 1 : 0
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
  count = var.use_tls ? 1 : 0
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
  count = var.use_tls ? 1 : 0
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
  count = var.use_tls ? 1 : 0
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
  count = var.use_tls ? 1 : 0
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
  count = var.use_tls ? 1 : 0
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
  count = var.use_tls ? 1 : 0
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

resource "juju_integration" "traefik_certificates" {
  count = var.use_tls ? 1 : 0
  model = var.model

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
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

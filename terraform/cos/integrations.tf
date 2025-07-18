# -------------- # Provided by Alertmanager --------------

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

resource "juju_integration" "otelcol_alertmanager_metrics" {
  model = var.model

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.self_metrics_endpoint
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.metrics_endpoint
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

# -------------- # Provided by Mimir --------------

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

resource "juju_integration" "mimir_tracing_otelcol_tracing_provider" {
  model = var.model

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.charm_tracing
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.receive_traces
  }
}


resource "juju_integration" "mimir_self_metrics_endpoint_otelcol_metrics_endpoint" {
  model = var.model

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.self_metrics_endpoint
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.metrics_endpoint
  }
}

resource "juju_integration" "mimir_logging_consumer_otelcol_logging_provider" {
  model = var.model

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.logging_consumer
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.receive_loki_logs
  }
}

# -------------- # Provided by Loki --------------

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

resource "juju_integration" "loki_logging_consumer_otelcol_logging_provider" {
  model = var.model

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.logging_consumer
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.receive_loki_logs
  }
}

resource "juju_integration" "loki_logging_otelcol_logging_consumer" {
  model = var.model

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.logging
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.send_loki_logs
  }
}

resource "juju_integration" "loki_tracing_otelcol_traicing_provider" {
  model = var.model

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.charm_tracing
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.receive_traces
  }
}
# -------------- # Provided by Tempo --------------

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

resource "juju_integration" "tempo_tracing_otelcol_tracing" {
  model = var.model

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.tracing
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.send_traces
  }
}

resource "juju_integration" "tempo_metrics_endpoint_otelcol_metrics_endpoint" {
  model = var.model

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.metrics_endpoint
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.metrics_endpoint
  }
}

resource "juju_integration" "tempo_logging_otelcol_logging_provider" {
  model = var.model

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.logging
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.receive_loki_logs
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

# -------------- # Provided by Catalogue --------------

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

# -------------- # Provided by Traefik --------------

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

# -------------- # Provided by OpenTelemetry Collector --------------

resource "juju_integration" "opentelemetry_collector_loki_metrics" {
  model = var.model

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.self_metrics_endpoint
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.metrics_endpoint
  }
}

resource "juju_integration" "opentelemetry_collector_mimir_metrics" {
  model = var.model

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.receive_remote_write
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.send_remote_write
  }
}

# -------------- # Provided by Grafana --------------

resource "juju_integration" "grafana_tracing_otelcol_traicing_provider" {
  model = var.model

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.charm_tracing
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.receive_traces
  }
}

# -------------- # Provided by Self-Signed-Certificates --------------

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

resource "juju_integration" "opentelemetry_collector_certificates" {
  count = var.internal_tls ? 1 : 0
  model = var.model

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.receive_server_cert
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

# -------------- # Provided by an external CA --------------

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

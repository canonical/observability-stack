# -------------- # Grafana Dashboard ---------------------

resource "juju_integration" "grafana_dashboards" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.endpoints.grafana_dashboard
    }
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.endpoints.grafana_dashboards_provider
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.endpoints.grafana_dashboards_provider
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.endpoints.grafana_dashboard
    }
  }

  model = var.model

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_dashboard
  }
}
# -------------- # Charm Tracing ------------------------

resource "juju_integration" "charm_tracing" {
  for_each = {
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.endpoints.charm_tracing
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.endpoints.charm_tracing
    }
    grafana = {
      app_name = module.grafana.app_name
      endpoint = module.grafana.endpoints.charm_tracing
    }
  }
  model = var.model

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.receive_traces
  }
}

# -------------- # Metrics Endpoint ----------------------
resource "juju_integration" "otelcol_metrics_endpoint" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.endpoints.self_metrics_endpoint
    }
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.endpoints.self_metrics_endpoint
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.endpoints.self_metrics_endpoint
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.endpoints.metrics_endpoint
    }
  }
  model = var.model

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.metrics_endpoint
  }
}

# -------------- # Provided by Alertmanager --------------

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



# -------------- # Grafana Source Integrations --------------
resource "juju_integration" "grafana_sources" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.endpoints.grafana_source
    }
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.endpoints.grafana_source
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.endpoints.grafana_source
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.endpoints.grafana_source
    }
  }

  model = var.model

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_source
  }
}

# -------------- # Provided by Mimir --------------



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


# -------------- # Provided by Tempo --------------

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

# -------------- # Provided by Catalogue --------------

# -------------- # Catalogue Integrations --------------
resource "juju_integration" "catalogue_integrations" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.endpoints.catalogue
    }
    grafana = {
      app_name = module.grafana.app_name
      endpoint = module.grafana.endpoints.catalogue
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.endpoints.catalogue
    }
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.endpoints.catalogue
    }
  }

  model = var.model

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.catalogue
  }

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
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

# -------------- # Provided by Self-Signed-Certificates --------------

# -------------- # Certificate Integrations --------------
resource "juju_integration" "internal_certificates" {
  for_each = var.internal_tls ? {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.endpoints.certificates
    }
    catalogue = {
      app_name = module.catalogue.app_name
      endpoint = module.catalogue.endpoints.certificates
    }
    grafana = {
      app_name = module.grafana.app_name
      endpoint = module.grafana.endpoints.certificates
    }
    opentelemetry_collector = {
      app_name = module.opentelemetry_collector.app_name
      endpoint = module.opentelemetry_collector.endpoints.receive_server_cert
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.endpoints.certificates
    }
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.endpoints.certificates
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.endpoints.certificates
    }
  } : {}

  model = var.model

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
  }

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
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

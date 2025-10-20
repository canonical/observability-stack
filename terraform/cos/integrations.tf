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

# -------------- # Receive Loki Logs ---------------------

resource "juju_integration" "otelcol_logging_provider" {
  for_each = {
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.endpoints.logging_consumer
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.endpoints.logging_consumer
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.endpoints.logging
    }
  }
  model = var.model

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.endpoints.receive_loki_logs
  }
}
# -------- Provided by Alertmanager --------------

resource "juju_integration" "alerting" {
  for_each = {
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.endpoints.alertmanager
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.endpoints.alertmanager
    }
  }
  model = var.model

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.alerting
  }
}


# -------------- # Provided by Loki --------------

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

# -------------- # Ingress --------------------------
resource "juju_integration" "ingress" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.endpoints.ingress
    }
    catalogue = {
      app_name = module.catalogue.app_name
      endpoint = module.catalogue.endpoints.ingress
    }
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.endpoints.ingress
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.endpoints.ingress
    }
  }
  model = var.model

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress
  }

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }
}


resource "juju_integration" "traefik_route" {
  for_each = {
    grafana = {
      app_name = module.grafana.app_name
      endpoint = module.grafana.endpoints.ingress
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.endpoints.ingress
    }
  }
  model = var.model

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.traefik_route
  }

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
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

# -------------- # Telemetry correlations ---------------------

resource "juju_integration" "traces_and_logs_correlation" {
  count = var.telemetry_correlation ? 1 : 0
  model = var.model

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.receive_datasource
  }

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.endpoints.send_datasource
  }
}

resource "juju_integration" "traces_and_metrics_correlation" {
  count = var.telemetry_correlation ? 1 : 0
  model = var.model

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.endpoints.receive_datasource
  }

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.endpoints.send_datasource
  }
}

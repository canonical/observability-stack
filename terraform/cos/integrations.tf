# -------------- # Grafana Dashboard ---------------------

resource "juju_integration" "grafana_dashboards" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.provides.grafana_dashboard
    }
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.provides.grafana_dashboards_provider
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.provides.grafana_dashboards_provider
    }
    otelcol = {
      app_name = module.opentelemetry_collector.app_name
      endpoint = module.opentelemetry_collector.provides.grafana_dashboards_provider
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.provides.grafana_dashboard
    }
  }

  model_uuid = var.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.grafana_dashboard
  }

  lifecycle { replace_triggered_by = [terraform_data.grafana_litestream_resource] }
}
# -------------- # Charm Tracing ------------------------

resource "juju_integration" "charm_tracing" {
  for_each = {
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.requires.charm_tracing
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.requires.charm_tracing
    }
  }
  model_uuid = var.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.provides.receive_traces
  }
}

resource "juju_integration" "charm_tracing_grafana" {
  model_uuid = var.model_uuid

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.charm_tracing
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.provides.receive_traces
  }

  lifecycle { replace_triggered_by = [terraform_data.grafana_litestream_resource] }
}

# -------------- # Metrics Endpoint ----------------------
resource "juju_integration" "otelcol_metrics_endpoint" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.provides.self_metrics_endpoint
    }
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.provides.self_metrics_endpoint
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.provides.self_metrics_endpoint
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.provides.metrics_endpoint
    }
  }
  model_uuid = var.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.requires.metrics_endpoint
  }
}


# -------------- # Grafana Source Integrations --------------
resource "juju_integration" "grafana_sources" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.provides.grafana_source
    }
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.provides.grafana_source
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.provides.grafana_source
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.provides.grafana_source
    }
  }

  model_uuid = var.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.grafana_source
  }

  lifecycle { replace_triggered_by = [terraform_data.grafana_litestream_resource] }
}

# -------------- # Receive Loki Logs ---------------------

resource "juju_integration" "otelcol_logging_provider" {
  for_each = {
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.requires.logging_consumer
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.requires.logging_consumer
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.requires.logging
    }
  }
  model_uuid = var.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.provides.receive_loki_logs
  }
}
# -------- Provided by Alertmanager --------------

resource "juju_integration" "alerting" {
  for_each = {
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.requires.alertmanager
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.requires.alertmanager
    }
  }
  model_uuid = var.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.provides.alerting
  }
}


# -------------- # Provided by Loki --------------

resource "juju_integration" "loki_logging_otelcol_logging_consumer" {
  model_uuid = var.model_uuid

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.provides.logging
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.requires.send_loki_logs
  }
}


# -------------- # Provided by Tempo --------------

resource "juju_integration" "tempo_tracing_otelcol_tracing" {
  model_uuid = var.model_uuid

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.provides.tracing
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.requires.send_traces
  }
}

resource "juju_integration" "tempo_send_remote_write_mimir_receive_remote_write" {
  model_uuid = var.model_uuid

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.requires.send-remote-write
  }

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.provides.receive_remote_write
  }
}

# -------------- # Provided by Catalogue --------------

# -------------- # Catalogue Integrations --------------
resource "juju_integration" "catalogue_integrations" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.requires.catalogue
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.requires.catalogue
    }
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.requires.catalogue
    }
  }

  model_uuid = var.model_uuid

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.provides.catalogue
  }

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }
}

resource "juju_integration" "catalogue_integration_grafana" {
  model_uuid = var.model_uuid

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.provides.catalogue
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.catalogue
  }

  lifecycle { replace_triggered_by = [terraform_data.grafana_litestream_resource] }
}

# -------------- # Provided by Traefik --------------

# -------------- # Ingress --------------------------
resource "juju_integration" "ingress" {
  for_each = {
    for k, v in {
      alertmanager = {
        app_name = module.alertmanager.app_name
        endpoint = module.alertmanager.requires.ingress
      }
      catalogue = {
        app_name = module.catalogue.app_name
        endpoint = module.catalogue.requires.ingress
      }
      mimir = {
        app_name = module.mimir.app_names.mimir_coordinator
        endpoint = module.mimir.requires.ingress
      }
      loki = {
        app_name = module.loki.app_names.loki_coordinator
        endpoint = module.loki.requires.ingress
      }
    } : k => v if var.ingress[k]
  }
  model_uuid = var.model_uuid

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress
  }

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }
}

resource "juju_integration" "grafana_ingress" {
  count = var.ingress.grafana ? 1 : 0

  model_uuid = var.model_uuid

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.ingress
  }

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress
  }

  lifecycle { replace_triggered_by = [terraform_data.grafana_ingress_interface, terraform_data.grafana_litestream_resource] }
}

resource "juju_integration" "traefik_route" {
  for_each = {
    for k, v in {
      opentelemetry_collector = {
        app_name = module.opentelemetry_collector.app_name
        endpoint = module.opentelemetry_collector.requires.ingress
      }
      tempo = {
        app_name = module.tempo.app_names.tempo_coordinator
        endpoint = module.tempo.requires.ingress
      }
    } : k => v if var.ingress[k]
  }
  model_uuid = var.model_uuid

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
  model_uuid = var.model_uuid

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.provides.receive_remote_write
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.requires.send_remote_write
  }
}

# -------------- # Provided by Self-Signed-Certificates --------------

# -------------- # Certificate Integrations --------------
resource "juju_integration" "internal_certificates" {
  for_each = var.internal_tls ? {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.requires.certificates
    }
    catalogue = {
      app_name = module.catalogue.app_name
      endpoint = module.catalogue.requires.certificates
    }
    grafana = {
      app_name = module.grafana.app_name
      endpoint = module.grafana.requires.certificates
    }
    opentelemetry_collector = {
      app_name = module.opentelemetry_collector.app_name
      endpoint = module.opentelemetry_collector.requires.receive_server_cert
    }
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.requires.certificates
    }
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.requires.certificates
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.requires.certificates
    }
  } : {}

  model_uuid = var.model_uuid

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
  count      = var.internal_tls ? 1 : 0
  model_uuid = var.model_uuid

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
  count      = local.tls_termination ? 1 : 0
  model_uuid = var.model_uuid

  application {
    offer_url = var.external_certificates_offer_url
  }

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.certificates
  }
}

resource "juju_integration" "external_grafana_ca_cert" {
  count      = local.tls_termination ? 1 : 0
  model_uuid = var.model_uuid

  application {
    offer_url = var.external_ca_cert_offer_url
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.receive_ca_cert
  }
}

resource "juju_integration" "external_otelcol_ca_cert" {
  count      = local.tls_termination ? 1 : 0
  model_uuid = var.model_uuid

  application {
    offer_url = var.external_ca_cert_offer_url
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.requires.receive_ca_cert
  }
}

# -------------- # Telemetry correlations ---------------------

resource "juju_integration" "traces_and_logs_correlation" {
  model_uuid = var.model_uuid

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.requires.receive_datasource
  }

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.provides.send_datasource
  }
}

resource "juju_integration" "traces_and_metrics_correlation" {
  model_uuid = var.model_uuid

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.requires.receive_datasource
  }

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.provides.send_datasource
  }
}

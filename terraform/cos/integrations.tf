# -------------- # Alerting --------------

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
  model_uuid = local.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.provides.alerting
  }
}

# -------------- # Catalogue --------------

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

  model_uuid = local.model_uuid

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
  model_uuid = local.model_uuid

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

# -------------- # Dashboards ---------------------

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

  model_uuid = local.model_uuid

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

# -------------- # Grafana Source --------------

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

  model_uuid = local.model_uuid

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

# -------------- # Logs ---------------------

resource "juju_integration" "otelcol_logging_provider" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.requires.logging
    }
    grafana = {
      app_name = module.grafana.app_name
      endpoint = module.grafana.requires.logging
    }
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
  model_uuid = local.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.provides.receive_loki_logs
  }
}

resource "juju_integration" "loki_logging_otelcol_logging_consumer" {
  model_uuid = local.model_uuid

  application {
    name     = module.loki.app_names.loki_coordinator
    endpoint = module.loki.provides.logging
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.requires.send_loki_logs
  }
}

# -------------- # Metrics ----------------------

resource "juju_integration" "metrics_endpoint" {
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
  model_uuid = local.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.requires.metrics_endpoint
  }
}

resource "juju_integration" "receive_remote_write" {
  for_each = {
    opentelemetry_collector = {
      app_name = module.opentelemetry_collector.app_name
      endpoint = module.opentelemetry_collector.requires.send_remote_write
    }
    tempo = {
      app_name = module.tempo.app_names.tempo_coordinator
      endpoint = module.tempo.requires.send-remote-write
    }
  }
  model_uuid = local.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.mimir.app_names.mimir_coordinator
    endpoint = module.mimir.provides.receive_remote_write
  }
}

# -------------- # Tracing ------------------------

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
  model_uuid = local.model_uuid

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
  model_uuid = local.model_uuid

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

resource "juju_integration" "tempo_tracing_otelcol_tracing" {
  model_uuid = local.model_uuid

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.provides.tracing
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.requires.send_traces
  }
}

# -------------- # Telemetry Correlations ---------------------

resource "juju_integration" "receive_datasource" {
  for_each = {
    loki = {
      app_name = module.loki.app_names.loki_coordinator
      endpoint = module.loki.provides.send_datasource
    }
    mimir = {
      app_name = module.mimir.app_names.mimir_coordinator
      endpoint = module.mimir.provides.send_datasource
    }
  }
  model_uuid = local.model_uuid

  application {
    name     = module.tempo.app_names.tempo_coordinator
    endpoint = module.tempo.requires.receive_datasource
  }

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }
}

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
      loki = {
        app_name = module.loki.app_names.loki_coordinator
        endpoint = module.loki.requires.ingress
      }
      mimir = {
        app_name = module.mimir.app_names.mimir_coordinator
        endpoint = module.mimir.requires.ingress
      }
    } : k => v if local.traefik_enabled && var.ingress[k]
  }
  model_uuid = local.model_uuid

  application {
    name     = module.traefik[0].app_name
    endpoint = module.traefik[0].endpoints.ingress
  }

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }
}

resource "juju_integration" "grafana_ingress" {
  count = local.traefik_enabled && var.ingress.grafana ? 1 : 0

  model_uuid = local.model_uuid

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.ingress
  }

  application {
    name     = module.traefik[0].app_name
    endpoint = module.traefik[0].endpoints.ingress
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
    } : k => v if local.traefik_enabled && var.ingress[k]
  }
  model_uuid = local.model_uuid

  application {
    name     = module.traefik[0].app_name
    endpoint = module.traefik[0].endpoints.traefik_route
  }

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }
}

# -------------- # Certificates --------------

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

  model_uuid = local.model_uuid

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
  count = local.traefik_enabled && var.internal_tls ? 1 : 0

  model_uuid = local.model_uuid

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.send-ca-cert
  }

  application {
    name     = module.traefik[0].app_name
    endpoint = module.traefik[0].endpoints.receive_ca_cert
  }
}

resource "juju_integration" "external_traefik_certificates" {
  count = local.traefik_enabled && local.tls_termination ? 1 : 0

  model_uuid = local.model_uuid

  application { offer_url = var.external_certificates_offer_url }
  application {
    name     = module.traefik[0].app_name
    endpoint = module.traefik[0].endpoints.certificates
  }
}

resource "juju_integration" "external_ca_cert" {
  for_each = local.tls_termination ? {
    grafana = {
      app_name = module.grafana.app_name
      endpoint = module.grafana.requires.receive_ca_cert
    }
    opentelemetry_collector = {
      app_name = module.opentelemetry_collector.app_name
      endpoint = module.opentelemetry_collector.requires.receive_ca_cert
    }
  } : {}

  model_uuid = local.model_uuid

  application { offer_url = var.external_ca_cert_offer_url }
  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }
}

# TODO: Add a comment separator
resource "juju_integration" "grafana_database" {
  count = local.grafana_db_required ? 1 : 0
  
  model_uuid = local.model_uuid

  application { offer_url = var.postgresql_offer_url }
  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.pgsql
  }
}

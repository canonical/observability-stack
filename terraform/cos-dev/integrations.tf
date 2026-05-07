# -------------- # Cluster integrations ---------------------

# Monolithic: coordinator ↔ single all-in-one worker
resource "juju_integration" "loki_cluster" {
  count      = var.topology == "monolithic" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.loki_coordinator.app_name
    endpoint = module.loki_coordinator.provides.loki_cluster
  }

  application {
    name     = module.loki_worker[0].app_name
    endpoint = module.loki_worker[0].requires.loki_cluster
  }
}

# Distributed: coordinator ↔ separate backend, read, write workers
resource "juju_integration" "loki_cluster_backend" {
  count      = var.topology == "distributed" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.loki_coordinator.app_name
    endpoint = module.loki_coordinator.provides.loki_cluster
  }

  application {
    name     = module.loki_worker_backend[0].app_name
    endpoint = module.loki_worker_backend[0].requires.loki_cluster
  }
}

resource "juju_integration" "loki_cluster_read" {
  count      = var.topology == "distributed" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.loki_coordinator.app_name
    endpoint = module.loki_coordinator.provides.loki_cluster
  }

  application {
    name     = module.loki_worker_read[0].app_name
    endpoint = module.loki_worker_read[0].requires.loki_cluster
  }
}

resource "juju_integration" "loki_cluster_write" {
  count      = var.topology == "distributed" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.loki_coordinator.app_name
    endpoint = module.loki_coordinator.provides.loki_cluster
  }

  application {
    name     = module.loki_worker_write[0].app_name
    endpoint = module.loki_worker_write[0].requires.loki_cluster
  }
}

resource "juju_integration" "mimir_cluster" {
  count      = var.topology == "monolithic" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.mimir_coordinator.app_name
    endpoint = module.mimir_coordinator.provides.mimir_cluster
  }

  application {
    name     = module.mimir_worker[0].app_name
    endpoint = module.mimir_worker[0].requires.mimir_cluster
  }
}

resource "juju_integration" "mimir_cluster_backend" {
  count      = var.topology == "distributed" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.mimir_coordinator.app_name
    endpoint = module.mimir_coordinator.provides.mimir_cluster
  }

  application {
    name     = module.mimir_worker_backend[0].app_name
    endpoint = module.mimir_worker_backend[0].requires.mimir_cluster
  }
}

resource "juju_integration" "mimir_cluster_read" {
  count      = var.topology == "distributed" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.mimir_coordinator.app_name
    endpoint = module.mimir_coordinator.provides.mimir_cluster
  }

  application {
    name     = module.mimir_worker_read[0].app_name
    endpoint = module.mimir_worker_read[0].requires.mimir_cluster
  }
}

resource "juju_integration" "mimir_cluster_write" {
  count      = var.topology == "distributed" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.mimir_coordinator.app_name
    endpoint = module.mimir_coordinator.provides.mimir_cluster
  }

  application {
    name     = module.mimir_worker_write[0].app_name
    endpoint = module.mimir_worker_write[0].requires.mimir_cluster
  }
}

resource "juju_integration" "tempo_cluster" {
  count      = var.topology == "monolithic" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = module.tempo_coordinator.provides.tempo_cluster
  }

  application {
    name     = module.tempo_worker[0].app_name
    endpoint = module.tempo_worker[0].requires.tempo_cluster
  }
}

resource "juju_integration" "tempo_cluster_querier" {
  count      = var.topology == "distributed" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "tempo-cluster"
  }

  application {
    name     = module.tempo_worker_querier[0].app_name
    endpoint = "tempo-cluster"
  }
}

resource "juju_integration" "tempo_cluster_query_frontend" {
  count      = var.topology == "distributed" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "tempo-cluster"
  }

  application {
    name     = module.tempo_worker_query_frontend[0].app_name
    endpoint = "tempo-cluster"
  }
}

resource "juju_integration" "tempo_cluster_ingester" {
  count      = var.topology == "distributed" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "tempo-cluster"
  }

  application {
    name     = module.tempo_worker_ingester[0].app_name
    endpoint = "tempo-cluster"
  }
}

resource "juju_integration" "tempo_cluster_distributor" {
  count      = var.topology == "distributed" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "tempo-cluster"
  }

  application {
    name     = module.tempo_worker_distributor[0].app_name
    endpoint = "tempo-cluster"
  }
}

resource "juju_integration" "tempo_cluster_compactor" {
  count      = var.topology == "distributed" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "tempo-cluster"
  }

  application {
    name     = module.tempo_worker_compactor[0].app_name
    endpoint = "tempo-cluster"
  }
}

resource "juju_integration" "tempo_cluster_metrics_generator" {
  count      = var.topology == "distributed" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "tempo-cluster"
  }

  application {
    name     = module.tempo_worker_metrics_generator[0].app_name
    endpoint = "tempo-cluster"
  }
}

# -------------- # SeaweedFS S3 storage -------------------

resource "juju_integration" "seaweedfs_loki" {
  count      = var.storage_backend == "seaweedfs" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.seaweedfs[0].app_name
    endpoint = module.seaweedfs[0].provides.s3
  }

  application {
    name     = module.loki_coordinator.app_name
    endpoint = "s3"
  }
}

resource "juju_integration" "seaweedfs_mimir" {
  count      = var.storage_backend == "seaweedfs" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.seaweedfs[0].app_name
    endpoint = module.seaweedfs[0].provides.s3
  }

  application {
    name     = module.mimir_coordinator.app_name
    endpoint = "s3"
  }
}

resource "juju_integration" "seaweedfs_tempo" {
  count      = var.storage_backend == "seaweedfs" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.seaweedfs[0].app_name
    endpoint = module.seaweedfs[0].provides.s3
  }

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = module.tempo_coordinator.requires.s3
  }
}

# -------------- # S3-integrator storage -------------------

resource "juju_integration" "s3_integrator_loki" {
  count      = var.storage_backend == "s3" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = juju_application.s3_integrator_loki[0].name
    endpoint = "s3-credentials"
  }

  application {
    name     = module.loki_coordinator.app_name
    endpoint = "s3"
  }
}

resource "juju_integration" "s3_integrator_mimir" {
  count      = var.storage_backend == "s3" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = juju_application.s3_integrator_mimir[0].name
    endpoint = "s3-credentials"
  }

  application {
    name     = module.mimir_coordinator.app_name
    endpoint = "s3"
  }
}

resource "juju_integration" "s3_integrator_tempo" {
  count      = var.storage_backend == "s3" ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = juju_application.s3_integrator_tempo[0].name
    endpoint = "s3-credentials"
  }

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = module.tempo_coordinator.requires.s3
  }
}

# -------------- # Grafana Dashboard ---------------------

resource "juju_integration" "grafana_dashboards" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.provides.grafana_dashboard
    }
    loki = {
      app_name = module.loki_coordinator.app_name
      endpoint = "grafana-dashboards-provider"
    }
    mimir = {
      app_name = module.mimir_coordinator.app_name
      endpoint = "grafana-dashboards-provider"
    }
    otelcol = {
      app_name = module.opentelemetry_collector.app_name
      endpoint = module.opentelemetry_collector.provides.grafana_dashboards_provider
    }
    tempo = {
      app_name = module.tempo_coordinator.app_name
      endpoint = module.tempo_coordinator.provides.grafana_dashboard
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
    loki = {
      app_name = module.loki_coordinator.app_name
      endpoint = "charm-tracing"
    }
    mimir = {
      app_name = module.mimir_coordinator.app_name
      endpoint = "charm-tracing"
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
    loki = {
      app_name = module.loki_coordinator.app_name
      endpoint = "self-metrics-endpoint"
    }
    mimir = {
      app_name = module.mimir_coordinator.app_name
      endpoint = "self-metrics-endpoint"
    }
    tempo = {
      app_name = module.tempo_coordinator.app_name
      endpoint = module.tempo_coordinator.provides.metrics_endpoint
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
    loki = {
      app_name = module.loki_coordinator.app_name
      endpoint = "grafana-source"
    }
    mimir = {
      app_name = module.mimir_coordinator.app_name
      endpoint = "grafana-source"
    }
    tempo = {
      app_name = module.tempo_coordinator.app_name
      endpoint = module.tempo_coordinator.provides.grafana_source
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
    loki = {
      app_name = module.loki_coordinator.app_name
      endpoint = "logging-consumer"
    }
    mimir = {
      app_name = module.mimir_coordinator.app_name
      endpoint = "logging-consumer"
    }
    tempo = {
      app_name = module.tempo_coordinator.app_name
      endpoint = module.tempo_coordinator.requires.logging
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

# -------------- # Alertmanager integrations --------------

resource "juju_integration" "alerting" {
  for_each = {
    loki = {
      app_name = module.loki_coordinator.app_name
      endpoint = "alertmanager"
    }
    mimir = {
      app_name = module.mimir_coordinator.app_name
      endpoint = "alertmanager"
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
    name     = module.loki_coordinator.app_name
    endpoint = "logging"
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
    name     = module.tempo_coordinator.app_name
    endpoint = module.tempo_coordinator.provides.tracing
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.requires.send_traces
  }
}

resource "juju_integration" "tempo_send_remote_write_mimir_receive_remote_write" {
  model_uuid = var.model_uuid

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = module.tempo_coordinator.requires.send_remote_write
  }

  application {
    name     = module.mimir_coordinator.app_name
    endpoint = "receive-remote-write"
  }
}

# -------------- # Catalogue Integrations --------------

resource "juju_integration" "catalogue_integrations" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.requires.catalogue
    }
    mimir = {
      app_name = module.mimir_coordinator.app_name
      endpoint = "catalogue"
    }
    tempo = {
      app_name = module.tempo_coordinator.app_name
      endpoint = module.tempo_coordinator.requires.catalogue
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
        app_name = module.loki_coordinator.app_name
        endpoint = "ingress"
      }
      mimir = {
        app_name = module.mimir_coordinator.app_name
        endpoint = "ingress"
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
        app_name = module.tempo_coordinator.app_name
        endpoint = module.tempo_coordinator.requires.ingress
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
    name     = module.mimir_coordinator.app_name
    endpoint = "receive-remote-write"
  }

  application {
    name     = module.opentelemetry_collector.app_name
    endpoint = module.opentelemetry_collector.requires.send_remote_write
  }
}

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
    loki = {
      app_name = module.loki_coordinator.app_name
      endpoint = "certificates"
    }
    mimir = {
      app_name = module.mimir_coordinator.app_name
      endpoint = "certificates"
    }
    opentelemetry_collector = {
      app_name = module.opentelemetry_collector.app_name
      endpoint = module.opentelemetry_collector.requires.receive_server_cert
    }
    tempo = {
      app_name = module.tempo_coordinator.app_name
      endpoint = module.tempo_coordinator.requires.certificates
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
    name     = module.tempo_coordinator.app_name
    endpoint = module.tempo_coordinator.requires.receive_datasource
  }

  application {
    name     = module.loki_coordinator.app_name
    endpoint = "send-datasource"
  }
}

resource "juju_integration" "traces_and_metrics_correlation" {
  model_uuid = var.model_uuid

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = module.tempo_coordinator.requires.receive_datasource
  }

  application {
    name     = module.mimir_coordinator.app_name
    endpoint = "send-datasource"
  }
}


mock_provider "juju" {}

variables {
  grafana                 = { storage_directives = { "foo" = "1G" } }
  loki                    = { storage_directives = { "foo" = "1G" } }
  opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  prometheus              = { storage_directives = { "foo" = "1G" } }
}

# --- otelcol is deployed unconditionally ---

run "otelcol_is_deployed" {
  command = plan

  assert {
    condition     = module.opentelemetry_collector.app_name == "otelcol"
    error_message = "Expected otelcol to be deployed with the default app name"
  }

  assert {
    condition     = startswith(local.channels.otelcol, "dev/")
    error_message = "Expected otelcol to track dev, got ${local.channels.otelcol}"
  }
}

# --- Logs fan in through otelcol, not straight into Loki ---

run "logs_are_funnelled_through_otelcol" {
  command = plan

  assert {
    condition = sort(keys(juju_integration.otelcol_logging_provider)) == tolist([
      "alertmanager", "grafana", "prometheus"
    ])
    error_message = "Unexpected set of components pushing logs into otelcol"
  }

  # otelcol's egress: everything it received gets forwarded to Loki.
  assert {
    condition = length([
      for a in juju_integration.loki_logging_otelcol_logging_consumer.application :
      a.name if a.name == module.opentelemetry_collector.app_name
      && a.endpoint == module.opentelemetry_collector.requires.send_loki_logs
    ]) == 1
    error_message = "Expected otelcol to forward collected logs to Loki over send-loki-logs"
  }
}

# --- Metrics are scraped by otelcol and remote-written into Prometheus ---

run "metrics_are_funnelled_through_otelcol" {
  command = plan

  assert {
    condition = sort(keys(juju_integration.metrics_endpoint)) == tolist([
      "alertmanager", "grafana", "loki", "prometheus"
    ])
    error_message = "Unexpected set of components scraped by otelcol"
  }

  # Prometheus scrapes nothing itself; otelcol is the only scraper, so Prometheus's own
  # metrics have to reach otelcol too.
  assert {
    condition     = contains(keys(juju_integration.metrics_endpoint), "prometheus")
    error_message = "Expected Prometheus's self-metrics to be scraped by otelcol"
  }

  assert {
    condition = length([
      for a in juju_integration.receive_remote_write.application :
      a.name if a.name == module.opentelemetry_collector.app_name
      && a.endpoint == module.opentelemetry_collector.requires.send_remote_write
    ]) == 1
    error_message = "Expected otelcol to remote-write collected metrics into Prometheus"
  }

  assert {
    condition     = length(juju_integration.traefik_self_monitoring_otelcol) == 1
    error_message = "Expected Traefik to be scraped by otelcol when ingress is enabled"
  }
}

# --- Traefik self-monitoring follows the traefik toggle ---

run "traefik_self_monitoring_absent_without_traefik" {
  command = plan

  variables {
    ingress = {
      alertmanager            = false
      catalogue               = false
      grafana                 = false
      loki                    = false
      opentelemetry_collector = false
      prometheus              = false
    }
  }

  assert {
    condition     = length(juju_integration.traefik_self_monitoring_otelcol) == 0
    error_message = "Unexpected Traefik self-monitoring integration when Traefik is not deployed"
  }
}

# --- otelcol forwards its own aggregated dashboards to Grafana ---

run "otelcol_dashboards_reach_grafana" {
  command = plan

  assert {
    condition     = contains(keys(juju_integration.grafana_dashboards), "otelcol")
    error_message = "Expected otelcol to send its dashboards to Grafana"
  }
}

# --- otelcol is exposed in the module outputs ---

run "otelcol_is_exposed_in_module_outputs" {
  command = plan

  assert {
    condition     = output.components.opentelemetry_collector != null
    error_message = "Expected otelcol to be exposed in the components output"
  }
}

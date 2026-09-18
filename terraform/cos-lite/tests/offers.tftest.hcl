mock_provider "juju" {}

variables {
  grafana                 = { storage_directives = { "foo" = "1G" } }
  loki                    = { storage_directives = { "foo" = "1G" } }
  opentelemetry_collector = { storage_directives = { "foo" = "1G" } }
  prometheus              = { storage_directives = { "foo" = "1G" } }
}

# --- Ingestion offers are fronted by the datastores, not otelcol ---
#
# otelcol is the fan-in point for COS Lite's *internal* telemetry only; external
# consumers keep pushing straight into Loki/Prometheus. This mirrors the COS module
# and is deliberate: `application_name` on `juju_offer` forces replacement, so
# retargeting a live offer would destroy and recreate it. Juju refuses to destroy an
# offer that still has active connections, so an upgrade of a deployment with live
# consumers would abort, and force-destroying would tear down cross-model relations
# and hand back a new offer UUID that consumers must `juju consume` again.

run "ingestion_offers_target_the_datastores" {
  command = plan

  assert {
    condition     = juju_offer.loki_logging.application_name == module.loki.app_name
    error_message = "Expected the loki-logging offer to be fronted by Loki, got ${juju_offer.loki_logging.application_name}"
  }

  assert {
    condition     = juju_offer.prometheus_receive_remote_write.application_name == module.prometheus.app_name
    error_message = "Expected the remote-write offer to be fronted by Prometheus, got ${juju_offer.prometheus_receive_remote_write.application_name}"
  }

  assert {
    condition     = juju_offer.prometheus_metrics_endpoint.application_name == module.prometheus.app_name
    error_message = "Expected the metrics-endpoint offer to be fronted by Prometheus, got ${juju_offer.prometheus_metrics_endpoint.application_name}"
  }
}

# --- The offer set is unchanged by the introduction of otelcol ---

run "offer_names_are_stable" {
  command = plan

  assert {
    condition = sort([
      juju_offer.alertmanager_karma_dashboard.name,
      juju_offer.grafana_dashboards.name,
      juju_offer.loki_logging.name,
      juju_offer.prometheus_metrics_endpoint.name,
      juju_offer.prometheus_receive_remote_write.name,
      ]) == tolist([
      "alertmanager-karma-dashboard",
      "grafana-dashboards",
      "loki-logging",
      "prometheus-metrics-endpoint",
      "prometheus-receive-remote-write",
    ])
    error_message = "The offer names must not change; consumers depend on them"
  }
}

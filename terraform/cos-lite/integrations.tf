# -------------- # Provided by Alertmanager --------------

resource "juju_integration" "alertmanager_grafana_dashboards" {
  model_uuid = var.model_uuid

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.grafana_dashboard
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "alertmanager_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.alertmanager
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.alerting
  }
}

resource "juju_integration" "alertmanager_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.metrics_endpoint
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.self_metrics_endpoint
  }
}

resource "juju_integration" "alertmanager_loki" {
  model_uuid = var.model_uuid

  application {
    name     = module.loki.app_name
    endpoint = module.loki.endpoints.alertmanager
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.alerting
  }
}

resource "juju_integration" "grafana_source_alertmanager" {
  model_uuid = var.model_uuid

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_source
  }
}

# -------------- # Provided by Grafana --------------

resource "juju_integration" "grafana_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.metrics_endpoint
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.metrics_endpoint
  }
}

# -------------- # Provided by Prometheus --------------

resource "juju_integration" "prometheus_grafana_dashboards_provider" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.grafana_dashboard
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "prometheus_grafana_source" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_source
  }
}

# -------------- # Provided by Loki --------------

resource "juju_integration" "loki_grafana_dashboards_provider" {
  model_uuid = var.model_uuid

  application {
    name     = module.loki.app_name
    endpoint = module.loki.endpoints.grafana_dashboard
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_dashboard
  }
}

resource "juju_integration" "loki_grafana_source" {
  model_uuid = var.model_uuid

  application {
    name     = module.loki.app_name
    endpoint = module.loki.endpoints.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.grafana_source
  }
}

resource "juju_integration" "loki_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.metrics_endpoint
  }

  application {
    name     = module.loki.app_name
    endpoint = module.loki.endpoints.metrics_endpoint
  }
}

# -------------- # Provided by Catalogue --------------

resource "juju_integration" "catalogue_alertmanager" {
  model_uuid = var.model_uuid

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.catalogue
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.endpoints.catalogue
  }
}

resource "juju_integration" "catalogue_grafana" {
  model_uuid = var.model_uuid

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.catalogue
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.catalogue
  }
}

resource "juju_integration" "catalogue_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.endpoints.catalogue
  }

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.catalogue
  }
}

# -------------- # Provided by Traefik --------------

resource "juju_integration" "alertmanager_ingress" {
  model_uuid = var.model_uuid

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
  model_uuid = var.model_uuid

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
  model_uuid = var.model_uuid

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.ingress
  }
}

resource "juju_integration" "prometheus_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress_per_unit
  }

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.ingress
  }
}

resource "juju_integration" "loki_ingress" {
  model_uuid = var.model_uuid

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress_per_unit
  }

  application {
    name     = module.loki.app_name
    endpoint = module.loki.endpoints.ingress
  }
}

resource "juju_integration" "traefik_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.metrics_endpoint
  }

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.metrics_endpoint
  }
}

# -------------- # Provided by Self-Signed-Certificates --------------

resource "juju_integration" "alertmanager_certificates" {
  count      = var.internal_tls ? 1 : 0
  model_uuid = var.model_uuid

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
  count      = var.internal_tls ? 1 : 0
  model_uuid = var.model_uuid

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
  count      = var.internal_tls ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.endpoints.certificates
  }
}

resource "juju_integration" "loki_certificates" {
  count      = var.internal_tls ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
  }

  application {
    name     = module.loki.app_name
    endpoint = module.loki.endpoints.certificates
  }
}

resource "juju_integration" "prometheus_certificates" {
  count      = var.internal_tls ? 1 : 0
  model_uuid = var.model_uuid

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
  }

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.certificates
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
    endpoint = module.grafana.endpoints.receive_ca_cert
  }
}

resource "juju_integration" "external_prom_ca_cert" {
  count      = local.tls_termination ? 1 : 0
  model_uuid = var.model_uuid

  application {
    offer_url = var.external_ca_cert_offer_url
  }

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.endpoints.receive_ca_cert
  }
}

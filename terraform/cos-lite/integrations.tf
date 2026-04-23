# -------------- # Provided by Alertmanager --------------

resource "juju_integration" "alertmanager_grafana_dashboards" {
  model_uuid = var.model_uuid

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.provides.grafana_dashboard
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.grafana_dashboard
  }
}

resource "juju_integration" "alertmanager_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.requires.alertmanager
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.provides.alerting
  }
}

resource "juju_integration" "alertmanager_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.requires.metrics_endpoint
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.provides.self_metrics_endpoint
  }
}

resource "juju_integration" "alertmanager_loki" {
  model_uuid = var.model_uuid

  application {
    name     = module.loki.app_name
    endpoint = module.loki.requires.alertmanager
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.provides.alerting
  }
}

resource "juju_integration" "grafana_source_alertmanager" {
  model_uuid = var.model_uuid

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.provides.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.grafana_source
  }
}

# -------------- # Provided by Grafana --------------

resource "juju_integration" "grafana_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.requires.metrics_endpoint
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.provides.metrics_endpoint
  }
}

# -------------- # Provided by Prometheus --------------

resource "juju_integration" "prometheus_grafana_dashboards_provider" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.provides.grafana_dashboard
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.grafana_dashboard
  }
}

resource "juju_integration" "prometheus_grafana_source" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.provides.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.grafana_source
  }
}

# -------------- # Provided by Loki --------------

resource "juju_integration" "loki_grafana_dashboards_provider" {
  model_uuid = var.model_uuid

  application {
    name     = module.loki.app_name
    endpoint = module.loki.provides.grafana_dashboard
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.grafana_dashboard
  }
}

resource "juju_integration" "loki_grafana_source" {
  model_uuid = var.model_uuid

  application {
    name     = module.loki.app_name
    endpoint = module.loki.provides.grafana_source
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.grafana_source
  }
}

resource "juju_integration" "loki_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.requires.metrics_endpoint
  }

  application {
    name     = module.loki.app_name
    endpoint = module.loki.provides.metrics_endpoint
  }
}

# -------------- # Provided by Catalogue --------------

resource "juju_integration" "catalogue_alertmanager" {
  model_uuid = var.model_uuid

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.provides.catalogue
  }

  application {
    name     = module.alertmanager.app_name
    endpoint = module.alertmanager.requires.catalogue
  }
}

resource "juju_integration" "catalogue_grafana" {
  model_uuid = var.model_uuid

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.provides.catalogue
  }

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.catalogue
  }
}

resource "juju_integration" "catalogue_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.provides.catalogue
  }

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.requires.catalogue
  }
}

# -------------- # Provided by Traefik --------------

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
    } : k => v if var.ingress[k]
  }

  model_uuid = var.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress
  }
}

//TODO: Feature this in COS
resource "juju_integration" "grafana_ingress" {
  count = var.ingress["grafana"] ? 1 : 0

  model_uuid = var.model_uuid

  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.ingress
  }

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress_per_unit
  }

  lifecycle { replace_triggered_by = [terraform_data.grafana_ingress_interface] }
}

resource "juju_integration" "ingress_per_unit" {
  for_each = {
    for k, v in {
      loki = {
        app_name = module.loki.app_name
        endpoint = module.loki.requires.ingress
      }
      prometheus = {
        app_name = module.prometheus.app_name
        endpoint = module.prometheus.requires.ingress
      }
    } : k => v if var.ingress[k]
  }

  model_uuid = var.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.traefik.app_name
    endpoint = module.traefik.endpoints.ingress_per_unit
  }
}

resource "juju_integration" "traefik_self_monitoring_prometheus" {
  model_uuid = var.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.requires.metrics_endpoint
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
    endpoint = module.alertmanager.requires.certificates
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
    endpoint = module.catalogue.requires.certificates
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
    endpoint = module.grafana.requires.certificates
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
    endpoint = module.loki.requires.certificates
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
    endpoint = module.prometheus.requires.certificates
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

resource "juju_integration" "external_prom_ca_cert" {
  count      = local.tls_termination ? 1 : 0
  model_uuid = var.model_uuid

  application {
    offer_url = var.external_ca_cert_offer_url
  }

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.requires.receive_ca_cert
  }
}

# -------------- # Grafana Dashboard ---------------------

resource "juju_integration" "grafana_dashboards" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.provides.grafana_dashboard
    }
    prometheus = {
      app_name = module.prometheus.app_name
      endpoint = module.prometheus.provides.grafana_dashboard
    }
    loki = {
      app_name = module.loki.app_name
      endpoint = module.loki.provides.grafana_dashboard
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
}

# -------------- # Grafana Source Integrations --------------

resource "juju_integration" "grafana_sources" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.provides.grafana_source
    }
    prometheus = {
      app_name = module.prometheus.app_name
      endpoint = module.prometheus.provides.grafana_source
    }
    loki = {
      app_name = module.loki.app_name
      endpoint = module.loki.provides.grafana_source
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
}

# -------------- # Provided by Alertmanager --------------

resource "juju_integration" "alerting" {
  for_each = {
    prometheus = {
      app_name = module.prometheus.app_name
      endpoint = module.prometheus.requires.alertmanager
    }
    loki = {
      app_name = module.loki.app_name
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

# -------------- # Metrics Endpoint ----------------------

resource "juju_integration" "metrics_endpoint" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.provides.self_metrics_endpoint
    }
    grafana = {
      app_name = module.grafana.app_name
      endpoint = module.grafana.provides.metrics_endpoint
    }
    loki = {
      app_name = module.loki.app_name
      endpoint = module.loki.provides.metrics_endpoint
    }
  }
  model_uuid = local.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.requires.metrics_endpoint
  }

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }
}

resource "juju_integration" "traefik_self_monitoring_prometheus" {
  count = local.traefik_enabled ? 1 : 0

  model_uuid = local.model_uuid

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.requires.metrics_endpoint
  }

  application {
    name     = module.traefik[0].app_name
    endpoint = module.traefik[0].endpoints.metrics_endpoint
  }
}

resource "juju_integration" "loki_logging" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.requires.logging
    }
    grafana = {
      app_name = module.grafana.app_name
      endpoint = module.grafana.requires.logging
    }
    prometheus = {
      app_name = module.prometheus.app_name
      endpoint = module.prometheus.requires.logging
    }
  }
  model_uuid = local.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.loki.app_name
    endpoint = module.loki.provides.logging
  }
}

# -------------- # Catalogue Integrations --------------

resource "juju_integration" "catalogue_integrations" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.requires.catalogue
    }
    prometheus = {
      app_name = module.prometheus.app_name
      endpoint = module.prometheus.requires.catalogue
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
    } : k => v if local.traefik_enabled && var.ingress[k]
  }

  model_uuid = local.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.traefik[0].app_name
    endpoint = module.traefik[0].endpoints.ingress
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
    } : k => v if local.traefik_enabled && var.ingress[k]
  }

  model_uuid = local.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.traefik[0].app_name
    endpoint = module.traefik[0].endpoints.ingress_per_unit
  }
}

# -------------- # Provided by Self-Signed-Certificates --------------

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
      app_name = module.loki.app_name
      endpoint = module.loki.requires.certificates
    }
    prometheus = {
      app_name = module.prometheus.app_name
      endpoint = module.prometheus.requires.certificates
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

# -------------- # Provided by an external CA --------------

resource "juju_integration" "external_traefik_certificates" {
  count = local.traefik_enabled && local.tls_termination ? 1 : 0

  model_uuid = local.model_uuid

  application { offer_url = var.external_certificates_offer_url }
  application {
    name     = module.traefik[0].app_name
    endpoint = module.traefik[0].endpoints.certificates
  }
}

resource "juju_integration" "external_grafana_ca_cert" {
  count = local.tls_termination ? 1 : 0

  model_uuid = local.model_uuid

  application { offer_url = var.external_ca_cert_offer_url }
  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.receive_ca_cert
  }
}

resource "juju_integration" "external_prom_ca_cert" {
  count = local.tls_termination ? 1 : 0

  model_uuid = local.model_uuid

  application { offer_url = var.external_ca_cert_offer_url }
  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.requires.receive_ca_cert
  }
}

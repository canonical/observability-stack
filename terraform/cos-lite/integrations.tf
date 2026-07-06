# -------------- # Alerting --------------

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

# -------------- # Catalogue --------------

resource "juju_integration" "catalogue_integrations" {
  for_each = {
    alertmanager = {
      app_name = module.alertmanager.app_name
      endpoint = module.alertmanager.requires.catalogue
    }
    grafana = {
      app_name = module.grafana.app_name
      endpoint = module.grafana.requires.catalogue
    }
    prometheus = {
      app_name = module.prometheus.app_name
      endpoint = module.prometheus.requires.catalogue
    }
  }
  model_uuid = local.model_uuid

  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.catalogue.app_name
    endpoint = module.catalogue.provides.catalogue
  }
}

# -------------- # Dashboards ---------------------

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

# -------------- # Grafana Source --------------

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

# -------------- # Logs ----------------------


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

# -------------- # Metrics ----------------------

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
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.prometheus.app_name
    endpoint = module.prometheus.requires.metrics_endpoint
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

# -------------- # Ingress --------------

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
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }

  application {
    name     = module.ssc[0].app_name
    endpoint = module.ssc[0].provides.certificates
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
    prometheus = {
      app_name = module.prometheus.app_name
      endpoint = module.prometheus.requires.receive_ca_cert
    }
  } : {}

  model_uuid = local.model_uuid

  application { offer_url = var.external_ca_cert_offer_url }
  application {
    name     = each.value.app_name
    endpoint = each.value.endpoint
  }
}

# -------------- # Database --------------

resource "juju_integration" "grafana_database" {
  count = local.grafana_db_enabled ? 1 : 0

  model_uuid = local.model_uuid

  application { offer_url = var.postgresql_offer_url }
  application {
    name     = module.grafana.app_name
    endpoint = module.grafana.requires.pgsql
  }
}

module "alertmanager" {
  source             = "git::https://github.com/canonical/alertmanager-k8s-operator//terraform"
  app_name           = var.alertmanager.app_name
  channel            = local.channels.alertmanager
  config             = var.alertmanager.config
  constraints        = var.alertmanager.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.alertmanager
  storage_directives = var.alertmanager.storage_directives
  units              = var.alertmanager.units
}

module "catalogue" {
  source             = "git::https://github.com/canonical/catalogue-k8s-operator//terraform"
  app_name           = var.catalogue.app_name
  channel            = local.channels.catalogue
  config             = var.catalogue.config
  constraints        = var.catalogue.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.catalogue
  storage_directives = var.catalogue.storage_directives
  units              = var.catalogue.units
}

module "grafana" {
  source             = "git::https://github.com/canonical/grafana-k8s-operator//terraform"
  app_name           = var.grafana.app_name
  channel            = local.channels.grafana
  config             = var.grafana.config
  constraints        = var.grafana.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.grafana
  storage_directives = var.grafana.storage_directives
  units              = var.grafana.units
}

module "loki" {
  source             = "git::https://github.com/canonical/loki-k8s-operator//terraform"
  app_name           = var.loki.app_name
  channel            = local.channels.loki
  config             = var.loki.config
  constraints        = var.loki.constraints
  model_uuid         = var.model_uuid
  storage_directives = var.loki.storage_directives
  revision           = local.revisions.loki
  units              = var.loki.units
}

module "prometheus" {
  source             = "git::https://github.com/canonical/prometheus-k8s-operator//terraform"
  app_name           = var.prometheus.app_name
  channel            = local.channels.prometheus
  config             = var.prometheus.config
  constraints        = var.prometheus.constraints
  model_uuid         = var.model_uuid
  storage_directives = var.prometheus.storage_directives
  revision           = local.revisions.prometheus
  units              = var.prometheus.units
}

module "ssc" {
  count       = var.internal_tls ? 1 : 0
  source      = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  app_name    = var.ssc.app_name
  channel     = local.channels.ssc
  config      = var.ssc.config
  constraints = var.ssc.constraints
  model_uuid  = var.model_uuid
  revision    = local.revisions.ssc
  units       = var.ssc.units
}

module "traefik" {
  source             = "git::https://github.com/canonical/traefik-k8s-operator//terraform"
  app_name           = var.traefik.app_name
  channel            = local.channels.traefik
  config             = var.traefik.config
  constraints        = var.traefik.constraints
  model_uuid         = var.model_uuid
  revision           = local.revisions.traefik
  storage_directives = var.traefik.storage_directives
  units              = var.traefik.units
}

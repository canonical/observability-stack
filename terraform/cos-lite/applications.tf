module "alertmanager" {
  source = "git::https://github.com/canonical/alertmanager-k8s-operator//terraform?ref=tf-0.31.2"

  app_name           = var.alertmanager.app_name
  base               = local.bases.o11y
  channel            = local.channels.alertmanager
  config             = var.alertmanager.config
  constraints        = var.alertmanager.constraints
  model_uuid         = local.model_uuid
  resources          = var.alertmanager.resources
  revision           = local.revisions.alertmanager
  storage_directives = var.alertmanager.storage_directives
  units              = var.alertmanager.units
}

module "catalogue" {
  source = "git::https://github.com/canonical/catalogue-k8s-operator//charm/terraform?ref=tf-3.0.3"

  app_name           = var.catalogue.app_name
  base               = local.bases.o11y
  channel            = local.channels.catalogue
  config             = var.catalogue.config
  constraints        = var.catalogue.constraints
  model_uuid         = local.model_uuid
  resources          = var.catalogue.resources
  revision           = local.revisions.catalogue
  storage_directives = var.catalogue.storage_directives
  units              = var.catalogue.units
}

module "grafana" {
  source           = "git::https://github.com/canonical/grafana-k8s-operator//terraform?ref=tf-12.4.2"
  replace_triggers = [terraform_data.grafana_litestream_resource.id]

  app_name           = var.grafana.app_name
  base               = local.bases.o11y
  channel            = local.channels.grafana
  config             = var.grafana.config
  constraints        = var.grafana.constraints
  model_uuid         = local.model_uuid
  resources          = var.grafana.resources
  revision           = local.revisions.grafana
  storage_directives = var.grafana.storage_directives
  units              = var.grafana.units
}

module "loki" {
  source = "git::https://github.com/canonical/loki-k8s-operator//terraform?ref=tf-3.7.2"

  app_name           = var.loki.app_name
  base               = local.bases.o11y
  channel            = local.channels.loki
  config             = var.loki.config
  constraints        = var.loki.constraints
  model_uuid         = local.model_uuid
  resources          = var.loki.resources
  revision           = local.revisions.loki
  storage_directives = var.loki.storage_directives
  units              = var.loki.units
}

module "prometheus" {
  source = "git::https://github.com/canonical/prometheus-k8s-operator//terraform?ref=tf-3.11.2"

  app_name           = var.prometheus.app_name
  base               = local.bases.o11y
  channel            = local.channels.prometheus
  config             = var.prometheus.config
  constraints        = var.prometheus.constraints
  model_uuid         = local.model_uuid
  resources          = var.prometheus.resources
  revision           = local.revisions.prometheus
  storage_directives = var.prometheus.storage_directives
  units              = var.prometheus.units
}

module "ssc" {
  source = "git::https://github.com/canonical/self-signed-certificates-operator//terraform?ref=rev655"
  count  = var.internal_tls ? 1 : 0

  app_name    = var.ssc.app_name
  base        = local.bases.ssc
  channel     = local.channels.ssc
  config      = var.ssc.config
  constraints = var.ssc.constraints
  model_uuid  = local.model_uuid
  revision    = local.revisions.ssc
  units       = var.ssc.units
}

module "traefik" {
  source = "git::https://github.com/canonical/traefik-k8s-operator//terraform?ref=traefik-k8s-rev360"
  count  = local.traefik_enabled ? 1 : 0

  app_name           = var.traefik.app_name
  base               = local.bases.traefik
  channel            = local.channels.traefik
  config             = var.traefik.config
  constraints        = var.traefik.constraints
  model_uuid         = local.model_uuid
  resources          = var.traefik.resources
  revision           = local.revisions.traefik
  storage_directives = var.traefik.storage_directives
  units              = var.traefik.units
}

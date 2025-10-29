module "alertmanager" {
  source             = "git::https://github.com/canonical/alertmanager-k8s-operator//terraform?ref=tf-provider-v0"
  app_name           = var.alertmanager.app_name
  channel            = var.channel
  config             = var.alertmanager.config
  constraints        = var.alertmanager.constraints
  model              = var.model
  revision           = var.alertmanager.revision
  storage_directives = var.alertmanager.storage_directives
  units              = var.alertmanager.units
}

module "catalogue" {
  source             = "git::https://github.com/canonical/catalogue-k8s-operator//terraform?ref=tf-provider-v0"
  app_name           = var.catalogue.app_name
  channel            = var.channel
  config             = var.catalogue.config
  constraints        = var.catalogue.constraints
  model              = var.model
  revision           = var.catalogue.revision
  storage_directives = var.catalogue.storage_directives
  units              = var.catalogue.units
}

module "grafana" {
  source             = "git::https://github.com/canonical/grafana-k8s-operator//terraform?ref=tf-provider-v0"
  app_name           = var.grafana.app_name
  channel            = var.channel
  config             = var.grafana.config
  constraints        = var.grafana.constraints
  model              = var.model
  revision           = var.grafana.revision
  storage_directives = var.grafana.storage_directives
  units              = var.grafana.units
}

module "loki" {
  source             = "git::https://github.com/canonical/loki-k8s-operator//terraform?ref=tf-provider-v0"
  app_name           = var.loki.app_name
  channel            = var.channel
  config             = var.loki.config
  constraints        = var.loki.constraints
  model              = var.model
  storage_directives = var.loki.storage_directives
  revision           = var.loki.revision
  units              = var.loki.units
}

module "prometheus" {
  source             = "git::https://github.com/canonical/prometheus-k8s-operator//terraform?ref=tf-provider-v0"
  app_name           = var.prometheus.app_name
  channel            = var.channel
  config             = var.prometheus.config
  constraints        = var.prometheus.constraints
  model              = var.model
  storage_directives = var.prometheus.storage_directives
  revision           = var.prometheus.revision
  units              = var.prometheus.units
}

module "ssc" {
  count       = var.internal_tls ? 1 : 0
  source      = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  app_name    = var.ssc.app_name
  channel     = var.ssc.channel
  config      = var.ssc.config
  constraints = var.ssc.constraints
  model       = var.model
  revision    = var.ssc.revision
  units       = var.ssc.units
}

module "traefik" {
  source             = "git::https://github.com/canonical/traefik-k8s-operator//terraform?ref=a8a0da68b9aa8e30e6ad00eac7aa552bcd88a8ef"
  app_name           = var.traefik.app_name
  channel            = var.traefik.channel
  config             = var.traefik.config
  constraints        = var.traefik.constraints
  model              = var.model
  revision           = var.traefik.revision
  storage_directives = var.traefik.storage_directives
  units              = var.traefik.units
}

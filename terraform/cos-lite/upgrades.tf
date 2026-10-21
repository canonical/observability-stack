# -------------- # CharmHub API -------------- #

data "juju_charm" "alertmanager_info" {
  charm   = "alertmanager-k8s"
  channel = local.channels.alertmanager
  base    = local.bases.o11y
}

data "juju_charm" "catalogue_info" {
  charm   = "catalogue-k8s"
  channel = local.channels.catalogue
  base    = local.bases.o11y
}

data "juju_charm" "grafana_info" {
  charm   = "grafana-k8s"
  channel = local.channels.grafana
  base    = local.bases.o11y
}

data "juju_charm" "loki_info" {
  charm   = "loki-k8s"
  channel = local.channels.loki
  base    = local.bases.o11y
}

data "juju_charm" "otelcol_info" {
  charm   = "opentelemetry-collector-k8s"
  channel = local.channels.otelcol
  base    = local.bases.o11y
}

data "juju_charm" "prometheus_info" {
  charm   = "prometheus-k8s"
  channel = local.channels.prometheus
  base    = local.bases.o11y
}

data "juju_charm" "ssc_info" {
  charm   = "self-signed-certificates"
  channel = local.channels.ssc
  base    = local.bases.ssc
}

data "juju_charm" "traefik_info" {
  charm   = "traefik-k8s"
  channel = local.channels.traefik
  base    = local.bases.traefik
}

# -------------- # State migrations -------------- #
# There are currently none ...

# moved {
#   from = module.foo
#   to   = module.foo[0]
# }

# -------------- # Replace triggers -------------- #

# There are currently none ...

# resource "terraform_data" "foo" {
  # triggers_replace ...
# }

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

data "juju_charm" "loki_coordinator_info" {
  charm   = "loki-coordinator-k8s"
  channel = local.channels.loki
  base    = local.bases.o11y
}

data "juju_charm" "loki_worker_info" {
  charm   = "loki-worker-k8s"
  channel = local.channels.loki
  base    = local.bases.o11y
}

data "juju_charm" "mimir_coordinator_info" {
  charm   = "mimir-coordinator-k8s"
  channel = local.channels.mimir
  base    = local.bases.o11y
}

data "juju_charm" "mimir_worker_info" {
  charm   = "mimir-worker-k8s"
  channel = local.channels.mimir
  base    = local.bases.o11y
}

data "juju_charm" "otelcol_info" {
  charm   = "opentelemetry-collector-k8s"
  channel = local.channels.otelcol
  base    = local.bases.o11y
}

data "juju_charm" "tempo_coordinator_info" {
  charm   = "tempo-coordinator-k8s"
  channel = local.channels.tempo
  base    = local.bases.o11y
}

data "juju_charm" "tempo_worker_info" {
  charm   = "tempo-worker-k8s"
  channel = local.channels.tempo
  base    = local.bases.o11y
}

data "juju_charm" "ssc_info" {
  charm   = "self-signed-certificates"
  channel = local.channels.ssc
  base    = local.bases.ssc
}

data "juju_charm" "s3_integrator_info" {
  charm   = "s3-integrator"
  channel = local.channels.s3_integrator
  base    = local.bases.s3_integrator
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

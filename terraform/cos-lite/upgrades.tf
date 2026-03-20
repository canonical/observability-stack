locals {
  # User input takes priority
  alertmanager_revision = var.alertmanager.revision != null ? var.alertmanager.revision : module.charmhub["alertmanager"].charm_revision
  catalogue_revision = var.catalogue.revision != null ? var.catalogue.revision : module.charmhub["catalogue"].charm_revision
  grafana_revision = var.grafana.revision != null ? var.grafana.revision : module.charmhub["grafana"].charm_revision
  loki_revision = var.loki.revision != null ? var.loki.revision : module.charmhub["loki"].charm_revision
  prometheus_revision = var.prometheus.revision != null ? var.prometheus.revision : module.charmhub["prometheus"].charm_revision
}

variable "charms_to_refresh" {
  description = "A map of charm names to query from Charmhub."
  type        = map(string)
  default = {
    alertmanager = "alertmanager-k8s"
    catalogue    = "catalogue-k8s"
    grafana      = "grafana-k8s"
    loki         = "loki-k8s"
    prometheus   = "prometheus-k8s"
  }
}

module "charmhub" {
  source   = "../charmhub"
  for_each = var.charms_to_refresh

  charm        = each.value
  channel      = var.channel
  base         = var.base
  architecture = "amd64"
}

# TODO: Remove
output "charm_revisions" {
  description = "The revision number for the specified charm channel and base"
  value       = { for k, v in module.charmhub : k => v.charm_revision }
}


# -------------- Upgrade logic --------------

locals {
  channel = "dev/edge"
}

data "juju_charm" "graphana_info" {
  charm   = "grafana-k8s"
  channel = local.channel
  base    = "ubuntu@24.04"
}

resource "juju_application" "grafana" {
  model_uuid = juju_model.test.uuid
  trust      = true

  charm {
    name     = "grafana-k8s"
    channel  = local.channel
    revision = data.juju_charm.graphana_info.revision
  }
}

resource "juju_model" "test" {
  name = "test-2131231"
}

resource "juju_application" "traefik" {
  model_uuid = juju_model.test.uuid
  trust      = true

  charm {
    name    = "traefik-k8s"
    channel = "latest/stable"
  }
}

resource "terraform_data" "interface" {
  input = data.juju_charm.graphana_info.requires["ingress"]
}

resource "juju_integration" "ingress" {
  model_uuid = juju_model.test.uuid

  application {
    name = juju_application.traefik.name
  }

  application {
    name     = juju_application.grafana.name
    endpoint = "ingress"
  }

  lifecycle {
    replace_triggered_by = [
      terraform_data.interface
    ]
  }
}
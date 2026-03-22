# -------------- Upgrade logic --------------

## -------- grafana.revision >= 175 ----------
# the ingress endpoint changes from traefik_route to ingress_per_app so we need a lifecycle to
# trigger integration replacement, otherwise the upgrade will fail
data "juju_charm" "grafana_info" {
  charm   = "grafana-k8s"
  channel = var.grafana.channel
  base    = var.base
}

resource "terraform_data" "interface" {
  input = data.juju_charm.grafana_info.requires["ingress"]
}

# -------------- End upgrade logic --------------
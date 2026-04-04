# -------------- Upgrade logic --------------

## -------- grafana.revision >= 174 ----------
# the ingress endpoint interface changes from traefik_route to ingress_per_app so we need a
# lifecycle to trigger integration replacement, otherwise the upgrade will fail
data "juju_charm" "grafana_info" {
  charm   = "grafana-k8s"
  channel = var.channel
  base    = var.base
}

resource "terraform_data" "grafana_ingress_interface" {
  input = data.juju_charm.grafana_info.requires["ingress"]
}

# -------------- End upgrade logic --------------
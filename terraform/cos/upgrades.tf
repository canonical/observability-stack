# -------------- # Application replace triggers -------------- #

# Grafana removed the litestream-image resource
#   The litestream-image resource was removed and given a Juju bug, we need to add a lifecycle to
#   trigger application replacement, otherwise the upgrade will fail
#   https://github.com/juju/juju/issues/21648
#   https://github.com/juju/juju/issues/22071
resource "terraform_data" "grafana_litestream_resource" {
  triggers_replace = contains(keys(data.juju_charm.grafana_info.resources), "litestream-image")
}

# -------------- # Integration replace triggers -------------- #

# Grafana ingress interface changed
#   The ingress endpoint interface changes from traefik_route to ingress_per_app so we need a
#   lifecycle to trigger integration replacement, otherwise the upgrade will fail
#   https://github.com/canonical/observability-stack/issues/165
resource "terraform_data" "grafana_ingress_interface" {
  triggers_replace = data.juju_charm.grafana_info.requires["ingress"]
}

# -------------- # CharmHub API -------------- #

data "juju_charm" "grafana_info" {
  charm   = "grafana-k8s"
  channel = var.channel
  base    = "ubuntu@24.04"
}

# -------------- # Replace triggers -------------- #

# -- Grafana -- #

# [application] Removed the litestream-image resource
#   Given a Juju bug, we need to trigger application replacement, otherwise the upgrade will fail
#   https://github.com/juju/juju/issues/21648
#   https://github.com/juju/juju/issues/22071
resource "terraform_data" "grafana_litestream_resource" {
  triggers_replace = contains(keys(data.juju_charm.grafana_info.resources), "litestream-image")
}

# [integration] Ingress interface changed
#   The ingress endpoint interface changes from traefik_route to ingress_per_app so we need to
#   trigger integration replacement, otherwise the upgrade will fail
#   https://github.com/canonical/observability-stack/issues/165
resource "terraform_data" "grafana_ingress_interface" {
  triggers_replace = lookup(data.juju_charm.grafana_info.requires, "ingress", "")
}

# -- Traefik -- #

# [integration] Malformed cert on upgrade
#   When upgraded, traefik's certificate is written to disk with double-quotes
#   causing 500 errors when using ingress since Traefik doesn't trust the cert.
#   https://github.com/canonical/traefik-k8s-operator/issues/668
resource "terraform_data" "traefik_revision" {
  triggers_replace = data.juju_charm.traefik_info.revision
}

# -------------- # CharmHub API -------------- #

data "juju_charm" "grafana_info" {
  charm   = "grafana-k8s"
  channel = var.channel
  base    = "ubuntu@24.04"
}

data "juju_charm" "traefik_info" {
  charm   = "traefik-k8s"
  channel = var.traefik.channel
  base    = "ubuntu@24.04"
}

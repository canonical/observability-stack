resource "juju_model" "cos" {
  name = "cos"
}

module "cos" {
  # Use the right source value depending on whether you are using cos or cos-lite
  source                          = "git::https://github.com/canonical/observability-stack//terraform/cos?ref=main"
  model_uuid                      = juju_model.cos.uuid
  channel                         = "dev/edge"
  
  # ... other inputs ...

  # Toggle a component's ingress integration to Traefik.
  ingress = {
    alertmanager = false
    catalogue    = false
    grafana      = true  # only enable ingress for Grafana
    loki         = false
    prometheus   = false
  }
}

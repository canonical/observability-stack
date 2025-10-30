variable "model" {
  type = string
}

data "juju_model" "model" {
  name  = var.model
  owner = "admin"
}

module "cos-lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=feat/tf-provider-v1"
  model_uuid   = data.juju_model.model.uuid
  channel      = "1/stable"
  internal_tls = "true"
}

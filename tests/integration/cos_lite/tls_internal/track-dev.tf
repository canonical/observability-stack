# [docs:providers]
terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}
# [docs:providers-end]

variable "model" { type = string }
data "juju_model" "cos" {
  name  = var.model
  owner = "admin"
}

# [docs:cos-lite]
module "cos-lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=main"
  model_uuid   = data.juju_model.cos.uuid
  risk         = "edge"
  internal_tls = true
}
# [docs:cos-lite-end]

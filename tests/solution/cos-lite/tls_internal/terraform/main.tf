terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0"
    }
  }
}

locals {
  # Output below for the solution test to connect jubilant to.
  model_name = "cos-lite-tls-internal"
}

module "cos-lite" {
  source       = "../../../../../terraform/cos-lite"
  model        = { name = local.model_name }
  internal_tls = true
}

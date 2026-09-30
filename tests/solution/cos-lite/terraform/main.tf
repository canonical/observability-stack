terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0"
    }
  }
}

variable "internal_tls" {
  description = "Passed straight through to the cos-lite module; overridden to exercise both TLS modes."
  type        = bool
  default     = true
}

locals {
  # Output below for the solution test to connect jubilant to.
  model_name = "cos-lite"
}

module "cos-lite" {
  source       = "../../../../terraform/cos-lite"
  model        = { name = local.model_name }
  internal_tls = var.internal_tls
}

terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0"
    }
  }
}

variable "tls_mode" {
  description = "Which TLS mode to deploy this solution under."
  type        = string
  default     = "tls-internal"

  validation {
    condition     = contains(keys(local.tls_mode_config), var.tls_mode)
    error_message = "tls_mode must be one of: ${join(", ", keys(local.tls_mode_config))}"
  }
}

variable "ingress_mode" {
  description = "Whether every component is fronted by ingress (Traefik) or not."
  type        = string
  default     = "ingress"

  validation {
    condition     = contains(keys(local.ingress_mode_config), var.ingress_mode)
    error_message = "ingress_mode must be one of: ${join(", ", keys(local.ingress_mode_config))}"
  }
}

locals {
  # Output below for the solution test to connect jubilant to.
  model_name = "cos-lite"

  # Keys match the mode tags scenarios use (e.g. `@tls-none`).
  tls_mode_config = {
    tls-internal = { internal_tls = true }
    tls-none     = { internal_tls = false }
  }

  # Keys match the mode tags scenarios use (e.g. `@no-ingress`). Blanket
  # on/off for every component, mirroring
  # terraform/cos-lite/presets/no-ingress.tfvars.
  ingress_mode_config = {
    ingress = {}
    no-ingress = {
      alertmanager            = false
      catalogue               = false
      grafana                 = false
      loki                    = false
      opentelemetry_collector = false
      prometheus              = false
    }
  }
}

module "cos-lite" {
  source       = "../../../../terraform/cos-lite"
  model        = { name = local.model_name }
  internal_tls = local.tls_mode_config[var.tls_mode].internal_tls
  ingress      = local.ingress_mode_config[var.ingress_mode]
}

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
  type    = bool
  default = true
}

variable "ingress" {
  type = object({
    alertmanager            = optional(bool, true)
    catalogue               = optional(bool, true)
    grafana                 = optional(bool, true)
    loki                    = optional(bool, true)
    opentelemetry_collector = optional(bool, true)
    prometheus              = optional(bool, true)
  })
  default = {}
}

# Whether an external CA terminates TLS instead of the module's own internal
# ssc. Only meaningful when internal_tls is true (tls_full/tls_external).
variable "external_ca" {
  type    = bool
  default = false
}

# The architecture of the cluster the solution is deployed on.
variable "arch" {
  type    = string
  default = "amd64"
}

locals {
  # Output below for the solution test to connect jubilant to.
  model_name = "cos-lite"

  ca_model_name = "${local.model_name}-ca"

  external_certificates_offer_url = var.external_ca ? "admin/${local.ca_model_name}.self-signed-certificates-certificates" : null
  external_ca_cert_offer_url      = var.external_ca ? "admin/${local.ca_model_name}.self-signed-certificates-send-ca-cert" : null

  # Juju deploys amd64 charms unless told otherwise, and the modules default their applications
  # to arch=amd64, so every application needs the architecture of the machine running the tests.
  constraints = "arch=${var.arch}"
}

resource "juju_model" "ca" {
  count = var.external_ca ? 1 : 0

  name        = local.ca_model_name
  config      = { automatically-retry-hooks = "true" }
  constraints = local.constraints
}

module "ssc" {
  source = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  count  = var.external_ca ? 1 : 0

  model_uuid = juju_model.ca[0].uuid

  offered_endpoints = ["certificates", "send-ca-cert"]
  constraints       = local.constraints
}

module "cos-lite" {
  source = "../../../../terraform/cos-lite"
  model  = { name = local.model_name, config = { automatically-retry-hooks = "true" }, constraints = local.constraints }

  depends_on = [module.ssc]

  internal_tls                    = var.internal_tls
  ingress                         = var.ingress
  external_certificates_offer_url = local.external_certificates_offer_url
  external_ca_cert_offer_url      = local.external_ca_cert_offer_url

  alertmanager            = { constraints = local.constraints }
  catalogue               = { constraints = local.constraints }
  grafana                 = { constraints = local.constraints }
  loki                    = { constraints = local.constraints }
  opentelemetry_collector = { constraints = local.constraints }
  prometheus              = { constraints = local.constraints }
  ssc                     = { constraints = local.constraints }
  traefik                 = { constraints = local.constraints }
}

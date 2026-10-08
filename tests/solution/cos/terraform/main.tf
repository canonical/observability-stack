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
    mimir                   = optional(bool, true)
    opentelemetry_collector = optional(bool, true)
    tempo                   = optional(bool, false)
  })
  default = {}
}

variable "external_ca" {
  type    = bool
  default = false
}

locals {
  # Output below for the solution test to connect jubilant to.
  model_name = "cos"

  # Must match terraform/seaweedfs's "app_name" default: used here as a
  # literal to avoid a dependency cycle with module.seaweedfs below.
  seaweedfs_app_name = "seaweedfs"

  ca_model_name = "${local.model_name}-ca"

  external_certificates_offer_url = var.external_ca ? "admin/${local.ca_model_name}.self-signed-certificates-certificates" : null
  external_ca_cert_offer_url      = var.external_ca ? "admin/${local.ca_model_name}.self-signed-certificates-send-ca-cert" : null
}

resource "juju_model" "ca" {
  count = var.external_ca ? 1 : 0

  name = local.ca_model_name
}

module "ssc" {
  source = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  count  = var.external_ca ? 1 : 0

  model_uuid = juju_model.ca[0].uuid

  offered_endpoints = ["certificates", "send-ca-cert"]
}

# Creates its own model rather than depending on one created here, since a
# model UUID known only after apply can't drive this module's internal
# create-vs-lookup-by-UUID logic at plan time.
module "cos" {
  source = "../../../../terraform/cos"
  model  = { name = local.model_name }

  depends_on = [module.ssc]

  internal_tls                    = var.internal_tls
  ingress                         = var.ingress
  external_certificates_offer_url = local.external_certificates_offer_url
  external_ca_cert_offer_url      = local.external_ca_cert_offer_url

  # In-cluster S3-compatible store, avoiding external S3 credentials in this
  # smoke test.
  s3_endpoint   = "http://${local.seaweedfs_app_name}.cos.svc.cluster.local:8333"
  s3_access_key = "placeholder"
  s3_secret_key = "placeholder"

  # Single unit: the default of 3 requires an external PostgreSQL offer
  # (see terraform/cos/variables.tf) that this smoke test doesn't stand up.
  grafana = { units = 1 }

  # Tests usually run on a single host, so the HA charms won't schedule
  anti_affinity = false
}

# Looked up by name rather than passed as a module output, to avoid a
# dependency cycle with module.seaweedfs below.
data "juju_model" "cos" {
  name  = local.model_name
  owner = "admin"

  depends_on = [module.cos]
}

module "seaweedfs" {
  source     = "../../../../terraform/seaweedfs"
  app_name   = local.seaweedfs_app_name
  model_uuid = data.juju_model.cos.uuid

  depends_on = [module.cos]
}

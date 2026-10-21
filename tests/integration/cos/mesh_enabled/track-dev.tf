terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0"
    }
  }
}

variable "model" {
  type = string
}

data "juju_model" "model" {
  name  = var.model
  owner = "admin"
}

variable "mesh" {
  type    = bool
  default = false
}

variable "istio_model" {
  type    = string
  default = ""
}

data "juju_model" "istio-model" {
  count = var.mesh ? 1 : 0
  name  = var.istio_model
  owner = "admin"
}

variable "s3_endpoint" {
  type = string
}

variable "s3_secret_key" {
  type = string
}

variable "s3_access_key" {
  type = string
}

module "istio" {
  count      = var.mesh ? 1 : 0
  source     = "git::https://github.com/canonical/service-mesh//charms/istio-k8s/terraform"
  channel    = "dev/edge"
  model_uuid = data.juju_model.istio-model[0].uuid
}

module "cos" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos"
  depends_on   = [module.istio] # The control plane must exist before COS components join the mesh.
  model        = { uuid = data.juju_model.model.uuid }
  risk         = "edge"
  internal_tls = false
  mesh_enabled = var.mesh

  s3_endpoint   = var.s3_endpoint
  s3_secret_key = var.s3_secret_key
  s3_access_key = var.s3_access_key

  alertmanager      = { units = 1 }
  grafana           = { units = 1 }
  loki_coordinator  = { units = 1 }
  loki_worker       = { backend_units = 1, read_units = 1, write_units = 1 }
  mimir_coordinator = { units = 1 }
  mimir_worker      = { backend_units = 1, read_units = 1, write_units = 1 }
  tempo_coordinator = { units = 1 }
  tempo_worker      = { compactor_units = 1, distributor_units = 1, ingester_units = 1, metrics_generator_units = 1, querier_units = 1, query_frontend_units = 1 }
}

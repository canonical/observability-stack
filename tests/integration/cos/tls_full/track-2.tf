module "ssc" {
  source = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  model  = var.ca_model
}

variable "ca_model" {
  type = string
}

module "cos" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos?ref=feat/refactor-buckets"
  model        = var.cos_model
  channel      = "2/edge"
  internal_tls = "true"
  external_certificates_offer_url = module.ssc.offers.certificates.url

  s3_endpoint       = var.s3_endpoint
  s3_secret_key     = var.s3_secret_key
  s3_access_key     = var.s3_access_key

  loki_coordinator  = { units = 1 }
  loki_worker       = { backend_units = 1, read_units = 1, write_units = 1 }
  mimir_coordinator = { units = 1 }
  mimir_worker      = { backend_units = 1, read_units = 1, write_units = 1 }
  tempo_coordinator = { units = 1 }
  tempo_worker      = { compactor_units = 1, distributor_units = 1, ingester_units = 1, metrics_generator_units = 1, querier_units = 1, query_frontend_units = 1 }
}

variable "cos_model" {
  type = string
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

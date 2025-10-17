module "ssc" {
  source = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  model  = var.ca_model
}

variable "ca_model" {
  type = string
}

module "cos-lite" {
  # TODO: Add a branch to the module
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model        = var.cos_model
  channel      = "1/stable"
  internal_tls = "true"
  external_certificates_offer_url = module.ssc.offers.certificates.url
}

variable "cos_model" {
  type = string
}

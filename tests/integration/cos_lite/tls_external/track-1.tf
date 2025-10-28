module "ssc" {
  source = "git::https://github.com/canonical/self-signed-certificates-operator//terraform"
  model  = var.ca_model
}

variable "ca_model" {
  type = string
}

module "cos-lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=tf-provider-v0"
  model        = var.cos_model
  channel      = "1/stable"
  internal_tls = "false"
  external_certificates_offer_url = module.ssc.offers.certificates.url
}

variable "cos_model" {
  type = string
}

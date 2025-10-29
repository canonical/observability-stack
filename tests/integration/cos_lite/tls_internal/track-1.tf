module "cos-lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=tf-provider-v0"
  model        = var.model
  channel      = "1/stable"
  internal_tls = "true"
}

variable "model" {
  type = string
}

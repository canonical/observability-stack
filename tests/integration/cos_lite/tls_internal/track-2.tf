module "cos-lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model        = var.model
  channel      = "2/edge"
  internal_tls = "true"
}

variable "model" {
  type = string
}

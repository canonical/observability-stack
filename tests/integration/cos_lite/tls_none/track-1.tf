module "cos-lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model        = var.model
  channel      = "1/stable"
  internal_tls = "false"
}

variable "model" {
  type = string
}

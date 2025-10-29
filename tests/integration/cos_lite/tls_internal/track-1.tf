module "cos-lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model_uuid = var.model_uuid
  channel      = "1/stable"
  internal_tls = "true"
}

variable "model" {
  type = string
}

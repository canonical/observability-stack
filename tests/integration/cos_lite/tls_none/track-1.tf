module "cos-lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=feat/tf-provider-v1"
  model_uuid = var.model_uuid
  channel      = "1/stable"
  internal_tls = "false"
}

variable "model" {
  type = string
}

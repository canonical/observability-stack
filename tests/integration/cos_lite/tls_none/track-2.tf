module "cos-lite" {
  source       = "git::https://github.com/canonical/observability-stack//terraform/cos-lite?ref=tf-provider-v0"
  model        = var.model
  channel      = "2/edge"
  internal_tls = "false"
  traefik      = { channel = "latest/edge" }  # TODO: Switch to latest/stable when rev257 hits stable
}

variable "model" {
  type = string
}

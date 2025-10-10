module "cos-lite" {
  source  = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model   = var.model
  channel = var.channel
}

variable "model" {
  type = string
}

variable "channel" {
  type = string
}

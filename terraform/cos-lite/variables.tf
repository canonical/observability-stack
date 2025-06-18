variable "channel" {
  description = "Channel that the charms are (unless overwritten by external_channels) deployed from"
  type        = string
}

variable "model" {
  description = "Reference to an existing model resource or data source for the model to deploy to"
  type        = string
}

variable "use_tls" {
  description = "Specify whether to use TLS or not for coordinator-worker communication. By default, TLS is enabled through self-signed-certificates"
  type        = bool
  default     = true
}

# -------------- # External channels --------------
# O11y does not own these charms, so we allow users to specify their channels directly.

variable "ssc_channel" {
  description = "Channel that the self-signed certificates charm is deployed from"
  type        = string
  default     = "1/stable"
}

variable "traefik_channel" {
  description = "Channel that the Traefik charm is deployed from"
  type        = string
  default     = "latest/stable"
}

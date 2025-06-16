variable "channel" {
  description = "Charms channel"
  type        = string
  default     = "latest/edge"
}

variable "model" {
  description = "Model name"
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
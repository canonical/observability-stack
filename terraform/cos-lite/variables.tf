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

# -------------- # Charm revisions --------------

variable "alertmanager_revision" {
  description = "Revision number of the Alertmanager charm"
  type        = number
  default     = null
}

variable "catalogue_revision" {
  description = "Revision number of the Catalogue charm"
  type        = number
  default     = null
}

variable "grafana_revision" {
  description = "Revision number of the Grafana charm"
  type        = number
  default     = null
}

variable "loki_revision" {
  description = "Revision number of the Loki charm"
  type        = number
  default     = null
}

variable "prometheus_revision" {
  description = "Revision number of the Prometheus charm"
  type        = number
  default     = null
}

variable "ssc_revision" {
  description = "Revision number of the self-signed certificates charm"
  type        = number
  default     = null
}

variable "traefik_revision" {
  description = "Revision number of the Traefik charm"
  type        = number
  default     = null
}

# We use constraints to set AntiAffinity in K8s
# https://discourse.charmhub.io/t/pod-priority-and-affinity-in-juju-charms/4091/13?u=jose

# FIXME: Passing an empty constraints value to the Juju Terraform provider currently
# causes the operation to fail due to https://github.com/juju/terraform-provider-juju/issues/344
# Therefore, we set a default value of "arch=amd64" for all applications.

locals {
  tls_termination = var.external_certificates_offer_url != null ? true : false
}

variable "channel" {
  description = "Channel that the applications are (unless overwritten by external_channels) deployed from"
  type        = string
}

variable "model" {
  description = "Reference to an existing model resource or data source for the model to deploy to"
  type        = string
}

variable "internal_tls" {
  description = "Specify whether to use TLS or not for internal COS communication. By default, TLS is enabled using self-signed-certificates"
  type        = bool
  default     = true
}

variable "external_certificates_offer_url" {
  description = "A Juju offer URL (e.g. admin/external-ca.certificates) of a CA providing the 'tls_certificates' integration for Traefik to supply it with server certificates."
  type        = string
  default     = null
}

variable "alertmanager" {
  type = object({
    app_name           = optional(string, "alertmanager")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default = {}
}

variable "catalogue" {
  type = object({
    app_name           = optional(string, "catalogue")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default = {}
}

variable "grafana" {
  type = object({
    app_name           = optional(string, "grafana")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default = {}
}

variable "loki" {
  type = object({
    app_name           = optional(string, "loki")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default = {}
}

variable "prometheus" {
  type = object({
    app_name           = optional(string, "prometheus")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default = {}
}

variable "ssc" {
  type = object({
    app_name           = optional(string, "ca")
    channel            = optional(string, "1/stable")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default = {}
}

variable "traefik" {
  type = object({
    app_name           = optional(string, "traefik")
    channel            = optional(string, "latest/stable")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default = {}
}

# -------------- # Application unit/scale --------------

variable "alertmanager_units" {
  description = "Unit count/scale of the Alertmanager application"
  type        = number
  default     = 1
}

variable "catalogue_units" {
  description = "Unit count/scale of the Catalogue application"
  type        = number
  default     = 1
}

variable "grafana_units" {
  description = "Unit count/scale of the Grafana application"
  type        = number
  default     = 1
}

variable "loki_units" {
  description = "Unit count/scale of the Loki application"
  type        = number
  default     = 1
}

variable "prometheus_units" {
  description = "Unit count/scale of the Prometheus application"
  type        = number
  default     = 1
}

variable "ssc_units" {
  description = "Unit count/scale of the self-signed certificates application"
  type        = number
  default     = 1
}

variable "traefik_units" {
  description = "Unit count/scale of the Traefik application"
  type        = number
  default     = 1
}

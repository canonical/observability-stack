# We use constraints to set AntiAffinity in K8s
# https://discourse.charmhub.io/t/pod-priority-and-affinity-in-juju-charms/4091/13?u=jose

# FIXME: Passing an empty constraints value to the Juju Terraform provider currently
# causes the operation to fail due to https://github.com/juju/terraform-provider-juju/issues/344
# Therefore, we set a default value of "arch=amd64" for all applications.

locals {
  # https://github.com/juju/terraform-provider-juju/issues/972
  tls_termination = var.external_certificates_offer_url != null ? true : false
}

# TODO: Discuss how this was missed bc we don't have any base terraform tests. TF plan would catch this error
variable "base" {
  description = "The operating system on which to deploy. E.g. ubuntu@22.04. Changing this value for machine charms will trigger a replace by terraform. Check Charmhub for per-charm base support."
  default     = "ubuntu@24.04"
  type        = string
}

variable "channel" {
  description = "Channel that the applications are (unless overwritten by individual channels) deployed from"
  type        = string
  default     = "dev/edge"

  # validation {
  #   # the TF Juju provider correctly identifies invalid risks; no need to validate it
  #   condition     = startswith(var.channel, "dev/")
  #   error_message = "The track of the channel must be 'dev/'. e.g. 'dev/edge'."
  # }
}

variable "model_uuid" {
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

  validation {
    condition = (
      (var.external_certificates_offer_url == null && var.external_ca_cert_offer_url == null) ||
      (var.external_certificates_offer_url != null && var.external_ca_cert_offer_url != null)
    )
    error_message = "external_certificates_offer_url and external_ca_cert_offer_url must be supplied together (either both set or both null)."
  }
}

variable "external_ca_cert_offer_url" {
  description = "A Juju offer URL (e.g. admin/external-ca.send-ca-cert) of a CA providing the 'certificate_transfer' integration for applications to trust ingress via Traefik."
  type        = string
  default     = null
}

# -------------- # Application configurations --------------

variable "alertmanager" {
  type = object({
    app_name           = optional(string, "alertmanager")
    channel            = optional(string, "dev/edge")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for Alertmanager. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "catalogue" {
  type = object({
    app_name           = optional(string, "catalogue")
    channel            = optional(string, "dev/edge")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for Catalogue. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

# TODO: Update all charms to surface their channel input, since we will have fine-grained channels per charm
# TODO: Update the channel defaults to be the track
variable "grafana" {
  type = object({
    app_name           = optional(string, "grafana")
    channel            = optional(string, "dev/edge")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for Grafana. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "loki" {
  type = object({
    app_name           = optional(string, "loki")
    channel            = optional(string, "dev/edge")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for Loki. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "prometheus" {
  type = object({
    app_name           = optional(string, "prometheus")
    channel            = optional(string, "dev/edge")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for Prometheus. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
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
  default     = {}
  description = "Application configuration for self-signed-certificates. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
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
  default     = {}
  description = "Application configuration for Traefik. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

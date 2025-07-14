# We use constraints to set AntiAffinity in K8s
# https://discourse.charmhub.io/t/pod-priority-and-affinity-in-juju-charms/4091/13?u=jose

# FIXME: Passing an empty constraints value to the Juju Terraform provider currently
# causes the operation to fail due to https://github.com/juju/terraform-provider-juju/issues/344
# Therefore, we set a default value of "arch=amd64" for all applications.

locals {
  clouds          = ["aws", "self-managed"] # list of k8s clouds where this COS module can be deployed.
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
  description = "A Juju offer URL of a CA providing the 'tls_certificates' integration for Traefik to supply it with server certificates"
  type        = string
  default     = null
}

variable "cloud" {
  description = "Kubernetes cloud or environment where this COS module will be deployed (e.g self-managed, aws)"
  type        = string
  default     = "self-managed"
  validation {
    condition     = contains(local.clouds, var.cloud)
    error_message = "Allowed values are: ${join(", ", local.clouds)}."
  }
}

variable "anti_affinity" {
  description = "Enable anti-affinity constraints across all HA modules (Mimir, Loki, Tempo)"
  type        = bool
  default     = true
}

# -------------- # S3 storage configuration --------------

variable "s3_integrator_channel" {
  description = "Channel that the s3-integrator application is deployed from"
  type        = string
  default     = "2/edge"
}

variable "s3_endpoint" {
  description = "S3 endpoint"
  type        = string
}

variable "s3_access_key" {
  description = "S3 access-key credential"
  type        = string
  sensitive   = true
}

variable "s3_secret_key" {
  description = "S3 secret-key credential"
  type        = string
  sensitive   = true
}

variable "loki_bucket" {
  description = "Loki bucket name"
  type        = string
  sensitive   = true
}

variable "mimir_bucket" {
  description = "Mimir bucket name"
  type        = string
  sensitive   = true
}

variable "tempo_bucket" {
  description = "Tempo bucket name"
  type        = string
  sensitive   = true
}

# -------------- # Application configurations --------------

variable "alertmanager" {
  type = object({
    app_name           = optional(string, "alertmanager") # without default, will give "known after apply"
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

variable "grafana_agent" {
  type = object({
    app_name           = optional(string, "grafana-agent")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default = {}
}

variable "loki_coordinator" {
  type = object({
    config                 = optional(map(string), {})
    constraints            = optional(string, "arch=amd64")
    revision               = optional(number, null)
    s3_integrator_channel  = optional(string, "2/edge")
    s3_integrator_revision = optional(number, 157) # FIXME: https://github.com/canonical/observability/issues/342
    storage_directives     = optional(map(string), {})
    units                  = optional(number, 3)
  })
  default = {}
}

variable "loki_worker" {
  type = object({
    backend_config     = optional(map(string), {})
    read_config        = optional(map(string), {})
    write_config       = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    backend_units      = optional(number, 3)
    read_units         = optional(number, 3)
    write_units        = optional(number, 3)
  })
  default = {}
}

variable "mimir_coordinator" {
  type = object({
    config                 = optional(map(string), {})
    constraints            = optional(string, "arch=amd64")
    revision               = optional(number, null)
    s3_integrator_channel  = optional(string, "2/edge")
    s3_integrator_revision = optional(number, 157) # FIXME: https://github.com/canonical/observability/issues/342
    storage_directives     = optional(map(string), {})
    units                  = optional(number, 3)
  })
  default = {}
}

variable "mimir_worker" {
  type = object({
    backend_config     = optional(map(string), {})
    read_config        = optional(map(string), {})
    write_config       = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    backend_units      = optional(number, 3)
    read_units         = optional(number, 3)
    write_units        = optional(number, 3)
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

variable "tempo_coordinator" {
  type = object({
    config                 = optional(map(string), {})
    constraints            = optional(string, "arch=amd64")
    revision               = optional(number, null)
    storage_directives     = optional(map(string), {})
    units                  = optional(number, 3)
    s3_integrator_channel  = optional(string, "2/edge")
    s3_integrator_revision = optional(number, 157) # FIXME: https://github.com/canonical/observability/issues/342
  })
  default = {}
}

variable "tempo_worker" {
  type = object({
    querier_config           = optional(map(string), {})
    query_frontend_config    = optional(map(string), {})
    ingester_config          = optional(map(string), {})
    distributor_config       = optional(map(string), {})
    compactor_config         = optional(map(string), {})
    metrics_generator_config = optional(map(string), {})
    constraints              = optional(string, "arch=amd64")
    revision                 = optional(number, null)
    storage_directives       = optional(map(string), {})
    compactor_units          = optional(number, 3)
    distributor_units        = optional(number, 3)
    ingester_units           = optional(number, 3)
    metrics_generator_units  = optional(number, 3)
    querier_units            = optional(number, 3)
    query_frontend_units     = optional(number, 3)
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

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
  default     = "2/stable"
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
  description = "A Juju offer URL of a CA providing the 'tls_certificates' integration for Traefik to supply it with server certificates"
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
  default     = "loki"
}

variable "mimir_bucket" {
  description = "Mimir bucket name"
  type        = string
  sensitive   = true
  default     = "mimir"
}

variable "tempo_bucket" {
  description = "Tempo bucket name"
  type        = string
  sensitive   = true
  default     = "tempo"
}

# -------------- # Application configurations --------------

variable "alertmanager" {
  type = object({
    app_name           = optional(string, "alertmanager")
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
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for Catalogue. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
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
  default     = {}
  description = "Application configuration for Grafana. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "loki_coordinator" {
  type = object({
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 3)
  })
  default     = {}
  description = "Application configuration for Loki Coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
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
  default     = {}
  description = "Application configuration for all Loki Workers. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "mimir_coordinator" {
  type = object({
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 3)
  })
  default     = {}
  description = "Application configuration for Mimir Coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
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
  default     = {}
  description = "Application configuration for all Mimir Workers. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "opentelemetry_collector" {
  type = object({
    app_name           = optional(string, "otelcol")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for OpenTelemetry Collector. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
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
  description = "Application configuration for Self-signed-certificates. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "s3_integrator" {
  type = object({
    channel            = optional(string, "2/edge")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for all S3-integrators in coordinated workers. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "tempo_coordinator" {
  type = object({
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 3)
  })
  default     = {}
  description = "Application configuration for Tempo Coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
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
  default     = {}
  description = "Application configuration for all Tempo workers. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
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

# We use constraints to set AntiAffinity in K8s
# https://discourse.charmhub.io/t/pod-priority-and-affinity-in-juju-charms/4091/13?u=jose

# FIXME: Passing an empty constraints value to the Juju Terraform provider currently
# causes the operation to fail due to https://github.com/juju/terraform-provider-juju/issues/344
# Therefore, we set a default value of "arch=amd64" for all applications.

variable "risk" {
  description = "Risk level that the applications are (unless overwritten by individual channels) deployed from"
  type        = string
  default     = "edge"
}

variable "base" {
  description = "The operating system on which to deploy. E.g. ubuntu@24.04. Check Charmhub for per-charm base support."
  default     = "ubuntu@24.04"
  type        = string
}

variable "model_uuid" {
  description = "Reference to an existing model resource or data source for the model to deploy to"
  type        = string
}

# -------------- # Topology configuration --------------

variable "topology" {
  description = "Deployment topology: 'monolithic' (single role-all worker per component) or 'distributed' (separate workers per role)."
  type        = string
  default     = "monolithic"
  validation {
    condition     = contains(["monolithic", "distributed"], var.topology)
    error_message = "topology must be either 'monolithic' or 'distributed'."
  }
}

# -------------- # Storage backend configuration --------------

variable "storage_backend" {
  description = "Storage backend: 'seaweedfs' (built-in S3-compatible storage) or 's3' (external S3/Ceph via s3-integrator)."
  type        = string
  default     = "seaweedfs"
  validation {
    condition     = contains(["seaweedfs", "s3"], var.storage_backend)
    error_message = "storage_backend must be either 'seaweedfs' or 's3'."
  }
}

# -------------- # TLS configurations --------------

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

# -------------- # Ingress configurations --------------

variable "ingress" {
  description = "Per-component toggle for ingress integrations"
  type = object({
    alertmanager            = optional(bool, true)
    catalogue               = optional(bool, true)
    grafana                 = optional(bool, true)
    loki                    = optional(bool, true)
    mimir                   = optional(bool, true)
    opentelemetry_collector = optional(bool, true)
    tempo                   = optional(bool, true)
  })
  default = {}
}

# -------------- # S3 storage configuration (required when storage_backend = "s3") --------------

variable "s3_endpoint" {
  description = "S3 endpoint URL. Required when storage_backend is 's3'."
  type        = string
  default     = null
}

variable "s3_access_key" {
  description = "S3 access-key credential. Required when storage_backend is 's3'."
  type        = string
  sensitive   = true
  default     = null
}

variable "s3_secret_key" {
  description = "S3 secret-key credential. Required when storage_backend is 's3'."
  type        = string
  sensitive   = true
  default     = null
}

variable "loki_bucket" {
  description = "Loki S3 bucket name"
  type        = string
  default     = "loki"
}

variable "mimir_bucket" {
  description = "Mimir S3 bucket name"
  type        = string
  default     = "mimir"
}

variable "tempo_bucket" {
  description = "Tempo S3 bucket name"
  type        = string
  default     = "tempo"
}

variable "s3_integrator" {
  type = object({
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration shared by all S3-integrators (one deployed per coordinated worker). For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
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
    app_name           = optional(string, "loki")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for the Loki coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "loki_worker" {
  type = object({
    app_name    = optional(string, "loki-worker")
    constraints = optional(string, "arch=amd64")
    revision    = optional(number, null)
    # Monolithic mode (role-all)
    config             = optional(map(string), {})
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
    # Distributed mode
    backend_config             = optional(map(string), {})
    read_config                = optional(map(string), {})
    write_config               = optional(map(string), {})
    backend_storage_directives = optional(map(string), {})
    read_storage_directives    = optional(map(string), {})
    write_storage_directives   = optional(map(string), {})
    backend_units              = optional(number, 1)
    read_units                 = optional(number, 1)
    write_units                = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for the Loki worker(s). For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "mimir_coordinator" {
  type = object({
    app_name           = optional(string, "mimir")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for the Mimir coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "mimir_worker" {
  type = object({
    app_name    = optional(string, "mimir-worker")
    constraints = optional(string, "arch=amd64")
    revision    = optional(number, null)
    # Monolithic mode (role-all)
    config             = optional(map(string), {})
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
    # Distributed mode
    backend_config             = optional(map(string), {})
    read_config                = optional(map(string), {})
    write_config               = optional(map(string), {})
    backend_storage_directives = optional(map(string), {})
    read_storage_directives    = optional(map(string), {})
    write_storage_directives   = optional(map(string), {})
    backend_units              = optional(number, 1)
    read_units                 = optional(number, 1)
    write_units                = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for the Mimir worker(s). For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
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

variable "seaweedfs" {
  type = object({
    app_name           = optional(string, "seaweedfs")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for SeaweedFS. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "ssc" {
  type = object({
    app_name           = optional(string, "ca")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for Self-signed-certificates. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "tempo_coordinator" {
  type = object({
    app_name           = optional(string, "tempo")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for the Tempo coordinator. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "tempo_worker" {
  type = object({
    app_name    = optional(string, "tempo-worker")
    constraints = optional(string, "arch=amd64")
    revision    = optional(number, null)
    # Monolithic mode (role-all)
    config             = optional(map(string), {})
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
    # Distributed mode
    querier_config                       = optional(map(string), {})
    query_frontend_config                = optional(map(string), {})
    ingester_config                      = optional(map(string), {})
    distributor_config                   = optional(map(string), {})
    compactor_config                     = optional(map(string), {})
    metrics_generator_config             = optional(map(string), {})
    querier_storage_directives           = optional(map(string), {})
    query_frontend_storage_directives    = optional(map(string), {})
    ingester_storage_directives          = optional(map(string), {})
    distributor_storage_directives       = optional(map(string), {})
    compactor_storage_directives         = optional(map(string), {})
    metrics_generator_storage_directives = optional(map(string), {})
    querier_units                        = optional(number, 1)
    query_frontend_units                 = optional(number, 1)
    ingester_units                       = optional(number, 1)
    distributor_units                    = optional(number, 1)
    compactor_units                      = optional(number, 1)
    metrics_generator_units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for the Tempo worker(s). For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "traefik" {
  type = object({
    app_name           = optional(string, "traefik")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for Traefik. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

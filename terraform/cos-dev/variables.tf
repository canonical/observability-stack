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

# -------------- # Network configurations --------------

variable "mesh" {
  description = "Configure the service mesh."
  type = object({
    enabled = optional(bool, false)
    cmr_urls = optional(object, {
      # TODO: Consider making these null?
      alermanager = ""
      catalogue   = ""
      grafana     = ""
      loki        = ""
      mimir       = ""
      tempo       = ""
    })
  })
  default = {}

  validation {
    condition     = !(var.mesh.enabled && var.reverse_proxy.enabled)
    error_message = "mesh_enabled and internal_tls cannot both be enabled at the same time."
  }
}

variable "reverse_proxy" {
  description = "Configure the reverse proxy."
  type = object({
    enabled = optional(bool, true)
    cmr_urls = optional(object, {
      certificates    = ""
      receive_ca_cert = ""
    })
  })
  default = {}

  validation {
    condition = (
      (var.reverse_proxy.cmr_urls.certificates == null && var.reverse_proxy.cmr_urls.receive_ca_cert == null) ||
      (var.reverse_proxy.cmr_urls.certificates != null && var.reverse_proxy.cmr_urls.receive_ca_cert != null)
    )
    error_message = "CMRs for certificates and receive_ca_cert must be supplied together (either both set or both null)."
  }
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

# TODO: Move the refactor efforts into a separate PR that the mesh team can branch from to get mesh merged:
# 1. buckets, reverse_proxy
# 2. I couldn't group s3_ because this has "sensitive" vars. Check if this is 100% not possible.
# What if we made the whole s3 var sensitive?
variable "s3_buckets" {
  description = "S3 bucket names for components"
  type = object({
    loki  = optional(string, "loki")
    mimir = optional(string, "mimir")
    tempo = optional(string, "tempo")
  })
  default = {}
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

variable "istio_beacon" {
  type = object({
    app_name           = optional(string, "istio-beacon")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for istio-beacon. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

variable "istio_ingress" {
  type = object({
    app_name           = optional(string, "istio-ingress")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for istio-ingress. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
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

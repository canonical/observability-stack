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

variable "model" {
  description = "Model configuration. When `uuid` is set, an existing model is looked up; otherwise a new model is created with the given fields. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/model"
  type = object({
    uuid = optional(string)
    name = optional(string, "cos-lite")
    cloud = optional(object({
      name   = string
      region = optional(string)
    }))
    annotations       = optional(map(string))
    config            = optional(map(string))
    constraints       = optional(string)
    credential        = optional(string)
    target_controller = optional(string)
  })
  default = {}

  validation {
    condition = var.model.uuid == null || (
      var.model.annotations == null &&
      var.model.cloud == null &&
      var.model.config == null &&
      var.model.constraints == null &&
      var.model.credential == null &&
      var.model.target_controller == null
    )
    error_message = "When `model.uuid` is set, the model already exists; do not also set `annotations`, `cloud`, `config`, `constraints`, `credential`, or `target_controller`."
  }

  validation {
    condition     = var.model.uuid != null || (var.model.name != null && length(var.model.name) > 0)
    error_message = "`model.name` must be non-empty when creating a model (i.e. when `model.uuid` is null)."
  }

  validation {
    condition     = var.model.uuid == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.model.uuid))
    error_message = "`model.uuid` must be a valid UUID."
  }
}

# -------------- # Network configurations --------------

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

variable "postgresql_offer_url" {
  description = "A Juju offer URL (e.g. admin/postgresql.database) of a PostgreSQL service providing the 'postgresql_client' integration for applications to connect to the database."
  type        = string
  default     = null

  validation {
    condition     = !(var.postgresql_offer_url == null && var.grafana.units > 1)
    error_message = "postgresql_offer_url must be supplied when Grafana is scaled > 1 due to its database requirements."
  }
}

# -------------- # Ingress configurations --------------

variable "ingress" {
  description = "Per-component toggle for ingress integrations"
  type = object({
    alertmanager = optional(bool, true)
    catalogue    = optional(bool, true)
    grafana      = optional(bool, true)
    loki         = optional(bool, true)
    prometheus   = optional(bool, true)
  })
  default = {}
}

# -------------- # Application configurations --------------

variable "alertmanager" {
  type = object({
    app_name           = optional(string, "alertmanager")
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    resources          = optional(map(string), {})
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
    resources          = optional(map(string), {})
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
    resources          = optional(map(string), {})
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
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    resources          = optional(map(string), {})
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
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    resources          = optional(map(string), {})
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
    config             = optional(map(string), {})
    constraints        = optional(string, "arch=amd64")
    resources          = optional(map(string), {})
    revision           = optional(number, null)
    storage_directives = optional(map(string), {})
    units              = optional(number, 1)
  })
  default     = {}
  description = "Application configuration for Traefik. For more details: https://registry.terraform.io/providers/juju/juju/latest/docs/resources/application"
}

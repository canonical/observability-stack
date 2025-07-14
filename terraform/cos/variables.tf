
# the list of kubernetes clouds where this COS module can be deployed.
locals {
  clouds = ["aws", "self-managed"]
}

variable "channel" {
  description = "Channel that the applications are (unless overwritten by external_channels) deployed from"
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

# -------------- # External channels --------------
# O11y does not own these applications, so we allow users to specify their channels directly.

variable "ssc_channel" {
  description = "Channel that the self-signed certificates application is deployed from"
  type        = string
  default     = "1/stable"
}

variable "s3_integrator_channel" {
  description = "Channel that the s3-integrator application is deployed from"
  type        = string
  default     = "2/edge"
}

variable "traefik_channel" {
  description = "Channel that the Traefik application is deployed from"
  type        = string
  default     = "latest/stable"
}

# -------------- # S3 storage configuration --------------

variable "s3_endpoint" {
  description = "S3 endpoint"
  type        = string
}

variable "s3_access_key" {
  description = "S3 access-key credential"
  type        = string
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

# -------------- # Application configs --------------

variable "alertmanager_config" {
  description = "Map of the Alertmanager configuration options"
  type        = map(string)
  default     = {}
}

variable "catalogue_config" {
  description = "Map of the Catalogue configuration options"
  type        = map(string)
  default     = {}
}

variable "grafana_config" {
  description = "Map of the Grafana configuration options"
  type        = map(string)
  default     = {}
}

variable "grafana_agent_config" {
  description = "Map of the Grafana agent configuration options"
  type        = map(string)
  default     = {}
}

variable "loki_coordinator_config" {
  description = "Map of the Loki coordinator configuration options"
  type        = map(string)
  default     = {}
}

variable "loki_backend_config" {
  description = "Map of the Loki backend worker configuration options"
  type        = map(string)
  default     = {}
}

variable "loki_read_config" {
  description = "Map of the Loki read worker configuration options"
  type        = map(string)
  default     = {}
}

variable "loki_write_config" {
  description = "Map of the Loki write worker configuration options"
  type        = map(string)
  default     = {}
}

variable "mimir_coordinator_config" {
  description = "Map of the Mimir coordinator configuration options"
  type        = map(string)
  default     = {}
}

variable "mimir_backend_config" {
  description = "Map of the Mimir backend worker configuration options"
  type        = map(string)
  default     = {}
}

variable "mimir_read_config" {
  description = "Map of the Mimir read worker configuration options"
  type        = map(string)
  default     = {}
}

variable "mimir_write_config" {
  description = "Map of the Mimir write worker configuration options"
  type        = map(string)
  default     = {}
}

variable "ssc_config" {
  description = "Map of the self-signed certificates configuration options"
  type        = map(string)
  default     = {}
}

variable "s3_integrator_config" {
  description = "Map of the s3-integrator configuration options"
  type        = map(string)
  default     = {}
}

variable "tempo_coordinator_config" {
  description = "Map of the Tempo coordinator configuration options"
  type        = map(string)
  default     = {}
}

variable "tempo_querier_config" {
  description = "Map of the Tempo querier worker configuration options"
  type        = map(string)
  default     = {}
}

variable "tempo_query_frontend_config" {
  description = "Map of the Tempo query-frontend worker configuration options"
  type        = map(string)
  default     = {}
}

variable "tempo_ingester_config" {
  description = "Map of the Tempo ingester worker configuration options"
  type        = map(string)
  default     = {}
}

variable "tempo_distributor_config" {
  description = "Map of the Tempo distributor worker configuration options"
  type        = map(string)
  default     = {}
}

variable "tempo_compactor_config" {
  description = "Map of the Tempo compactor worker configuration options"
  type        = map(string)
  default     = {}
}

variable "tempo_metrics_generator_config" {
  description = "Map of the Tempo metrics-generator worker configuration options"
  type        = map(string)
  default     = {}
}

variable "traefik_config" {
  description = "Map of the Traefik configuration options"
  type        = map(string)
  default     = {}
}

# -------------- # Application constraints --------------

# We use constraints to set AntiAffinity in K8s
# https://discourse.charmhub.io/t/pod-priority-and-affinity-in-juju-charms/4091/13?u=jose

# FIXME: Passing an empty constraints value to the Juju Terraform provider currently
# causes the operation to fail due to https://github.com/juju/terraform-provider-juju/issues/344
# Therefore, we set a default value of "arch=amd64" for all applications.

variable "alertmanager_constraints" {
  description = "String listing constraints for the Alertmanager application"
  type        = string
  default     = "arch=amd64"
}

variable "catalogue_constraints" {
  description = "String listing constraints for the Catalogue application"
  type        = string
  default     = "arch=amd64"
}

variable "grafana_constraints" {
  description = "String listing constraints for the Grafana application"
  type        = string
  default     = "arch=amd64"
}

variable "grafana_agent_constraints" {
  description = "String listing constraints for the Grafana agent application"
  type        = string
  default     = "arch=amd64"
}

variable "loki_coordinator_constraints" {
  description = "String listing constraints for the Loki coordinator application"
  type        = string
  default     = "arch=amd64"
}

variable "loki_worker_constraints" {
  description = "String listing constraints for the Loki worker application"
  type        = string
  default     = "arch=amd64"
}

variable "mimir_coordinator_constraints" {
  description = "String listing constraints for the Mimir coordinator application"
  type        = string
  default     = "arch=amd64"
}

variable "mimir_worker_constraints" {
  description = "String listing constraints for the Mimir worker application"
  type        = string
  default     = "arch=amd64"
}

variable "ssc_constraints" {
  description = "String listing constraints for the self-signed certificates application"
  type        = string
  default     = "arch=amd64"
}

variable "s3_integrator_constraints" {
  description = "String listing constraints for the s3-integrator application"
  type        = string
  default     = "arch=amd64"
}

variable "tempo_coordinator_constraints" {
  description = "String listing constraints for the Tempo coordinator application"
  type        = string
  default     = "arch=amd64"
}

variable "tempo_worker_constraints" {
  description = "String listing constraints for the Tempo worker application"
  type        = string
  default     = "arch=amd64"
}

variable "traefik_constraints" {
  description = "String listing constraints for the Traefik application"
  type        = string
  default     = "arch=amd64"
}

# -------------- # Application revisions --------------

variable "alertmanager_revision" {
  description = "Revision number of the Alertmanager application"
  type        = number
  default     = null
}

variable "catalogue_revision" {
  description = "Revision number of the Catalogue application"
  type        = number
  default     = null
}

variable "grafana_revision" {
  description = "Revision number of the Grafana application"
  type        = number
  default     = null
}

variable "grafana_agent_revision" {
  description = "Revision number of the Grafana agent application"
  type        = number
  default     = null
}

variable "loki_coordinator_revision" {
  description = "Revision number of the Loki coordinator application"
  type        = number
  default     = null
}

variable "loki_worker_revision" {
  description = "Revision number of the Loki worker application"
  type        = number
  default     = null
}

variable "mimir_coordinator_revision" {
  description = "Revision number of the Mimir coordinator application"
  type        = number
  default     = null
}

variable "mimir_worker_revision" {
  description = "Revision number of the Mimir worker application"
  type        = number
  default     = null
}

variable "ssc_revision" {
  description = "Revision number of the self-signed certificates application"
  type        = number
  default     = null
}

variable "s3_integrator_revision" {
  description = "Revision number of the s3-integrator application"
  type        = number
  default     = 157 # FIXME: https://github.com/canonical/observability/issues/342
}

variable "tempo_coordinator_revision" {
  description = "Revision number of the Tempo coordinator application"
  type        = number
  default     = null
}

variable "tempo_worker_revision" {
  description = "Revision number of the Tempo worker application"
  type        = number
  default     = null
}

variable "traefik_revision" {
  description = "Revision number of the Traefik application"
  type        = number
  default     = null
}

# -------------- # Application storage directives --------------

variable "alertmanager_storage_directives" {
  description = "Map of storage used by the Alertmanager application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "catalogue_storage_directives" {
  description = "Map of storage used by the Catalogue application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "grafana_storage_directives" {
  description = "Map of storage used by the Grafana application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "grafana_agent_storage_directives" {
  description = "Map of storage used by the Grafana agent application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "loki_coordinator_storage_directives" {
  description = "Map of storage used by the Loki coordinator application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "loki_worker_storage_directives" {
  description = "Map of storage used by the Loki worker application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "mimir_coordinator_storage_directives" {
  description = "Map of storage used by the Mimir coordinator application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "mimir_worker_storage_directives" {
  description = "Map of storage used by the Mimir worker application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "ssc_storage_directives" {
  description = "Map of storage used by the self-signed certificates application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "s3_integrator_storage_directives" {
  description = "Map of storage used by the s3-integrator application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "tempo_coordinator_storage_directives" {
  description = "Map of storage used by the Tempo coordinator application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "tempo_worker_storage_directives" {
  description = "Map of storage used by the Tempo worker application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "traefik_storage_directives" {
  description = "Map of storage used by the Traefik application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
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

variable "grafana_agent_units" {
  description = "Unit count/scale of the Grafana agent application"
  type        = number
  default     = 1
}

variable "loki_backend_units" {
  description = "Count/scale of Loki worker units with backend role"
  type        = number
  default     = 3
}

variable "loki_read_units" {
  description = "Count/scale of Loki worker units with read role"
  type        = number
  default     = 3
}

variable "loki_write_units" {
  description = "Count/scale of Loki worker units with write roles"
  type        = number
  default     = 3
}

variable "loki_coordinator_units" {
  description = "Count/scale of the Loki coordinator units"
  type        = number
  default     = 3
}

variable "mimir_backend_units" {
  description = "Count/scale of Mimir worker units with backend role"
  type        = number
  default     = 3
}

variable "mimir_read_units" {
  description = "Count/scale of Mimir worker units with read role"
  type        = number
  default     = 3
}

variable "mimir_write_units" {
  description = "Count/scale of Mimir worker units with write role"
  type        = number
  default     = 3
}

variable "mimir_coordinator_units" {
  description = "Count/scale of Mimir coordinator units"
  type        = number
  default     = 3
}

variable "ssc_units" {
  description = "Unit count/scale of the self-signed certificates application"
  type        = number
  default     = 1
}

variable "s3_integrator_units" {
  description = "Unit count/scale of the s3-integrator application"
  type        = number
  default     = 1
}

variable "tempo_compactor_units" {
  description = "Count/scale of Tempo worker units with compactor role"
  type        = number
  default     = 3
}

variable "tempo_distributor_units" {
  description = "Count/scale of Tempo worker units with distributor role"
  type        = number
  default     = 3
}

variable "tempo_ingester_units" {
  description = "Count/scale of Tempo worker units with ingester role"
  type        = number
  default     = 3
}

variable "tempo_metrics_generator_units" {
  description = "Count/scale of Tempo worker units with metrics-generator role"
  type        = number
  default     = 3
}

variable "tempo_querier_units" {
  description = "Count/scale of Tempo worker units with querier role"
  type        = number
  default     = 3
}

variable "tempo_query_frontend_units" {
  description = "Count/scale of Tempo worker units with query-frontend role"
  type        = number
  default     = 3
}

variable "tempo_coordinator_units" {
  description = "Count/scale of Tempo coordinator units"
  type        = number
  default     = 3
}

variable "traefik_units" {
  description = "Unit count/scale of the Traefik application"
  type        = number
  default     = 1
}

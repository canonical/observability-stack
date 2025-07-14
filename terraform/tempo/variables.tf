variable "model" {
  description = "Reference to an existing model resource or data source for the model to deploy to"
  type        = string
}

variable "channel" {
  description = "Channel that the applications are deployed from"
  type        = string
}

variable "anti_affinity" {
  description = "Enable anti-affinity constraints"
  type        = bool
  default     = true
}

# -------------- # S3 object storage --------------

variable "s3_integrator_channel" {
  description = "Channel that the s3-integrator application is deployed from"
  type        = string
  default     = "2/edge"
}

variable "s3_bucket" {
  description = "Bucket name"
  type        = string
  default     = "tempo"
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

variable "s3_endpoint" {
  description = "S3 endpoint"
  type        = string
}

# -------------- # App Names --------------

variable "querier_name" {
  description = "Name of the Tempo querier app"
  type        = string
  default     = "tempo-querier"
}

variable "query_frontend_name" {
  description = "Name of the Tempo query-frontend app"
  type        = string
  default     = "tempo-query-frontend"
}

variable "ingester_name" {
  description = "Name of the Tempo ingester app"
  type        = string
  default     = "tempo-ingester"
}

variable "distributor_name" {
  description = "Name of the Tempo distributor app"
  type        = string
  default     = "tempo-distributor"
}

variable "compactor_name" {
  description = "Name of the Tempo compactor app"
  type        = string
  default     = "tempo-compactor"
}

variable "metrics_generator_name" {
  description = "Name of the Tempo metrics-generator app"
  type        = string
  default     = "tempo-metrics-generator"
}

variable "s3_integrator_name" {
  description = "Name of the s3-integrator app"
  type        = string
  default     = "tempo-s3-integrator"
}

# -------------- # Configs --------------

variable "coordinator_config" {
  description = "Map of the coordinator configuration options"
  type        = map(string)
  default     = {}
}

variable "querier_config" {
  description = "Map of the querier worker configuration options"
  type        = map(string)
  default     = {}
}

variable "query_frontend_config" {
  description = "Map of the query-frontend worker configuration options"
  type        = map(string)
  default     = {}
}

variable "ingester_config" {
  description = "Map of the ingester worker configuration options"
  type        = map(string)
  default     = {}
}

variable "distributor_config" {
  description = "Map of the distributor worker configuration options"
  type        = map(string)
  default     = {}
}

variable "compactor_config" {
  description = "Map of the compactor worker configuration options"
  type        = map(string)
  default     = {}
}

variable "metrics_generator_config" {
  description = "Map of the metrics-generator worker configuration options"
  type        = map(string)
  default     = {}
}

variable "s3_integrator_config" {
  description = "Map of the s3-integrator configuration options"
  type        = map(string)
  default     = {}
}

# -------------- # Constraints --------------

# We use constraints to set AntiAffinity in K8s
# https://discourse.charmhub.io/t/pod-priority-and-affinity-in-juju-charms/4091/13?u=jose

# FIXME: Passing an empty constraints value to the Juju Terraform provider currently
# causes the operation to fail due to https://github.com/juju/terraform-provider-juju/issues/344
# Therefore, we set a default value of "arch=amd64" for all applications.

variable "coordinator_constraints" {
  description = "String listing constraints for the coordinator application"
  type        = string
  default     = "arch=amd64"

  validation {
    condition     = !(var.anti_affinity && var.coordinator_constraints != "arch=amd64")
    error_message = "Setting both custom charm constraints and anti-affinity to true is not allowed."
  }
}

variable "worker_constraints" {
  description = "String listing constraints for the worker application"
  type        = string
  default     = "arch=amd64"

  validation {
    condition     = !(var.anti_affinity && var.worker_constraints != "arch=amd64")
    error_message = "Setting both custom charm constraints and anti-affinity to true is not allowed."
  }
}

variable "s3_integrator_constraints" {
  description = "String listing constraints for the s3-integrator application"
  type        = string
  default     = "arch=amd64"

  validation {
    condition     = !(var.anti_affinity && var.s3_integrator_constraints != "arch=amd64")
    error_message = "Setting both custom charm constraints and anti-affinity to true is not allowed."
  }
}

# -------------- # Revisions --------------

variable "coordinator_revision" {
  description = "Revision number of the coordinator application"
  type        = number
  default     = null
}

variable "worker_revision" {
  description = "Revision number of the worker application"
  type        = number
  default     = null
}

variable "s3_integrator_revision" {
  description = "Revision number of the s3-integrator application"
  type        = number
  default     = 157 # FIXME: https://github.com/canonical/observability/issues/342
}

# -------------- # Storage directives --------------

variable "coordinator_storage_directives" {
  description = "Map of storage used by the coordinator application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "worker_storage_directives" {
  description = "Map of storage used by the worker application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "s3_integrator_storage_directives" {
  description = "Map of storage used by the s3-integrator application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

# -------------- # Units Per App --------------

variable "compactor_units" {
  description = "Number of Tempo worker units with compactor role"
  type        = number
  default     = 1
  validation {
    condition     = var.compactor_units >= 1
    error_message = "The number of units must be greater than or equal to 1."
  }
}

variable "distributor_units" {
  description = "Number of Tempo worker units with distributor role"
  type        = number
  default     = 1
  validation {
    condition     = var.distributor_units >= 1
    error_message = "The number of units must be greater than or equal to 1."
  }
}

variable "ingester_units" {
  description = "Number of Tempo worker units with ingester role"
  type        = number
  default     = 1
  validation {
    condition     = var.ingester_units >= 1
    error_message = "The number of units must be greater than or equal to 1."
  }
}

variable "metrics_generator_units" {
  description = "Number of Tempo worker units with metrics-generator role"
  type        = number
  default     = 1
  validation {
    condition     = var.metrics_generator_units >= 1
    error_message = "The number of units must be greater than or equal to 1."
  }
}

variable "coordinator_units" {
  description = "Number of Tempo coordinator units"
  type        = number
  default     = 1
  validation {
    condition     = var.coordinator_units >= 1
    error_message = "The number of units must be greater than or equal to 1."
  }
}

variable "querier_units" {
  description = "Number of Tempo worker units with querier role"
  type        = number
  default     = 1
  validation {
    condition     = var.querier_units >= 1
    error_message = "The number of units must be greater than or equal to 1."
  }
}
variable "query_frontend_units" {
  description = "Number of Tempo worker units with query-frontend role"
  type        = number
  default     = 1
  validation {
    condition     = var.query_frontend_units >= 1
    error_message = "The number of units must be greater than or equal to 1."
  }
}

variable "s3_integrator_units" {
  description = "Number of S3 integrator units"
  type        = number
  default     = 1
  validation {
    condition     = var.s3_integrator_units >= 1
    error_message = "The number of units must be greater than or equal to 1."
  }
}

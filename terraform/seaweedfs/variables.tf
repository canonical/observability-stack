variable "model_uuid" {
  description = "Reference to an existing model resource or data source for the model to deploy to"
  type        = string
}

variable "app_name" {
  description = "Application name for the SeaweedFS deployment"
  type        = string
  default     = "seaweedfs"
}

variable "channel" {
  description = "Channel that SeaweedFS is deployed from"
  type        = string
  default     = "latest/edge"
}

variable "revision" {
  description = "Revision number of the SeaweedFS application"
  type        = number
  default     = null
}

variable "config" {
  description = "Map of SeaweedFS configuration options"
  type        = map(string)
  default     = {}
}

# FIXME: Passing an empty constraints value to the Juju Terraform provider currently
# causes the operation to fail due to https://github.com/juju/terraform-provider-juju/issues/344
# Therefore, we set a default value of "arch=amd64" for all applications.

variable "constraints" {
  description = "String listing constraints for the SeaweedFS application"
  type        = string
  default     = "arch=amd64"
}

variable "storage_directives" {
  description = "Map of storage used by SeaweedFS, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

variable "units" {
  description = "Number of SeaweedFS units"
  type        = number
  default     = 1
  validation {
    condition     = var.units >= 1
    error_message = "The number of units must be greater than or equal to 1."
  }
}

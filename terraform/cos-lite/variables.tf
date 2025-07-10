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

# -------------- # External channels --------------
# O11y does not own these applications, so we allow users to specify their channels directly.

variable "ssc_channel" {
  description = "Channel that the self-signed certificates application is deployed from"
  type        = string
  default     = "1/stable"
}

variable "traefik_channel" {
  description = "Channel that the Traefik application is deployed from"
  type        = string
  default     = "latest/stable"
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

variable "loki_config" {
  description = "Map of the Loki configuration options"
  type        = map(string)
  default     = {}
}

variable "prometheus_config" {
  description = "Map of the Prometheus configuration options"
  type        = map(string)
  default     = {}
}

variable "ssc_config" {
  description = "Map of the self-signed certificates configuration options"
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

variable "loki_constraints" {
  description = "String listing constraints for the Loki application"
  type        = string
  default     = "arch=amd64"
}

variable "prometheus_constraints" {
  description = "String listing constraints for the Prometheus application"
  type        = string
  default     = "arch=amd64"
}

variable "ssc_constraints" {
  description = "String listing constraints for the self-signed certificates application"
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

variable "loki_revision" {
  description = "Revision number of the Loki application"
  type        = number
  default     = null
}

variable "prometheus_revision" {
  description = "Revision number of the Prometheus application"
  type        = number
  default     = null
}

variable "ssc_revision" {
  description = "Revision number of the self-signed certificates application"
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

variable "traefik_storage_directives" {
  description = "Map of storage used by the Traefik application, which defaults to 1 GB, allocated by Juju"
  type        = map(string)
  default     = {}
}

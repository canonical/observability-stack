terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

variable "charm" {
  description = "Name of the charm (e.g., postgresql)"
  type        = string
}

variable "channel" {
  description = "Channel name (e.g., 14/stable, 16/edge)"
  type        = string
}

variable "base" {
  description = "Base Ubuntu (e.g., ubuntu@22.04, ubuntu@24.04)"
  type        = string
}

variable "architecture" {
  description = "Architecture (e.g., amd64, arm64)"
  type        = string
  default     = "amd64"
}

data "http" "charmhub_info" {
  url = "https://api.charmhub.io/v2/charms/info/${var.charm}?fields=channel-map.revision.revision"

  request_headers = {
    Accept = "application/json"
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Failed to fetch charm info from Charmhub API"
    }
  }
}

locals {
  charmhub_response = jsondecode(data.http.charmhub_info.response_body)
  base_version      = split("@", var.base)[1]

  matching_channels = [
    for entry in local.charmhub_response["channel-map"] :
    entry if(
      entry.channel.name == var.channel &&
      entry.channel.base.channel == local.base_version &&
      entry.channel.base.architecture == var.architecture
    )
  ]

  revision = length(local.matching_channels) > 0 ? local.matching_channels[0].revision.revision : null
}

check "revision_found" {
  assert {
    condition     = local.revision != null
    error_message = "No matching revision found for charm '${var.charm}' with channel '${var.channel}', base '${var.base}', and architecture '${var.architecture}'. Please verify the combination exists in Charmhub."
  }
}

output "charm_revision" {
  description = "The revision number for the specified charm channel and base"
  value       = local.revision
}

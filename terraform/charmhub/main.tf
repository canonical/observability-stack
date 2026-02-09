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
  # base_version      = split("@", var.base)[1]

  matching_channels = [
    for entry in local.charmhub_response["channel-map"] :
    entry if(
      entry.channel.name == var.channel &&
      
      # TODO: I think we can ignore this base input if we assume that 24.04 is always dev/and track/2
      # TODO: Capture all matching JSON bodies for channel & architecture. Then validate that it's only one. If not, the user should be warned that the base needs to be specified.
      # E.g. you specify channel as 1/stable, but then base defaults to 24.04. This would fail bc 22.04 is for 1/stable

      # TODO: Test that this works with the product to charm channel mapping like the revisions override I have
      # curl "https://api.charmhub.io/v2/charms/info/alertmanager-k8s?fields=channel-map.revision.revision" | jq -r '.["channel-map"]

      # entry.channel.base.channel == local.base_version &&
      entry.channel.base.architecture == var.architecture
    )
  ]

  revision = length(local.matching_channels) > 0 ? local.matching_channels[0].revision.revision : null
}

check "revision_found" {
  assert {
    condition     = local.revision != null
    # TODO: Undo
    # error_message = "No matching revision found for charm '${var.charm}' with channel '${var.channel}', base '${var.base}', and architecture '${var.architecture}'. Please verify the combination exists in Charmhub."
    error_message = "No matching revision found for charm '${var.charm}' with channel '${var.channel}', and architecture '${var.architecture}'. Please verify the combination exists in Charmhub."
  }
}

output "charm_revision" {
  description = "The revision number for the specified charm channel and base"
  value       = local.revision
}

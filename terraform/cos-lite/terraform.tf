terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source = "juju/juju"
      # This PR introduced the `juju_charm` resource released in v1.4.0:
      #   https://github.com/canonical/observability-stack/pull/278
      version = ">= 1.4.0"
    }
  }
}
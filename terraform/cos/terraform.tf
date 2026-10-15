terraform {
  # Two constraints set this floor:
  #   - `variable` validation blocks referencing other variables require >= 1.9
  #   - the traefik-k8s-operator module declares `required_version = "~> 1.11"`
  required_version = ">= 1.11"
  required_providers {
    juju = {
      source = "juju/juju"
      # This PR introduced the `juju_charm` resource released in v1.4.0:
      #   https://github.com/canonical/observability-stack/pull/278
      version = ">= 1.4.0"
    }
  }
}

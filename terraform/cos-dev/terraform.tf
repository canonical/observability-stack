terraform {
  # Two constraints set this floor:
  #   - `variable` validation blocks referencing other variables require >= 1.9
  #   - the traefik-k8s-operator module declares `required_version = "~> 1.11"`
  required_version = ">= 1.11"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0"
    }
  }
}

terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0"
    }
  }
}

# All defaults: creates its own model ("cos-lite"), edge risk, self-signed TLS.
module "cos-lite" {
  source = "../../../../terraform/cos-lite"
}

# [docs:providers]
terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}
# [docs:providers-end]

# [docs:cos]
resource "juju_model" "cos" {
  name = "cos"
}
# [docs:cos-end]

# [docs:cos-lite]
resource "juju_model" "cos" {
  name = "cos-lite"
}
# [docs:cos-lite-end]

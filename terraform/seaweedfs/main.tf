resource "juju_application" "seaweedfs" {
  config             = var.config
  constraints        = var.constraints
  model_uuid         = var.model_uuid
  name               = var.app_name
  storage_directives = var.storage_directives
  trust              = true
  units              = var.units

  charm {
    name     = "seaweedfs-k8s"
    channel  = var.channel
    revision = var.revision
  }
}

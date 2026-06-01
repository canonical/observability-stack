# Model management: create internally or look up an existing model by UUID.

resource "juju_model" "cos" {
  count = local.create_model ? 1 : 0

  name = var.model.name

  dynamic "cloud" {
    for_each = var.model.cloud != null ? [var.model.cloud] : []
    content {
      name   = cloud.value.name
      region = cloud.value.region
    }
  }

  config = var.model.config

  # TODO: add timeouts when supported by the provider.
  # timeouts {
  #   create = var.model.create_timeout
  # }
}

data "juju_model" "cos" {
  count = local.create_model ? 0 : 1

  uuid = local.provided_model_uuid
}

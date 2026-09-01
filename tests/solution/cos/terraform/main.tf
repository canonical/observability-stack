terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0"
    }
  }
}

locals {
  # Output below for the solution test to connect jubilant to.
  model_name = "cos"

  # Must match terraform/seaweedfs's "app_name" default: used here as a
  # literal to avoid a dependency cycle with module.seaweedfs below.
  seaweedfs_app_name = "seaweedfs"
}

# Creates its own model rather than depending on one created here, since a
# model UUID known only after apply can't drive this module's internal
# create-vs-lookup-by-UUID logic at plan time.
module "cos" {
  source = "../../../../terraform/cos"
  model  = { name = local.model_name }

  # In-cluster S3-compatible store, avoiding external S3 credentials in this
  # smoke test.
  s3_endpoint   = "http://${local.seaweedfs_app_name}.cos.svc.cluster.local:8333"
  s3_access_key = "placeholder"
  s3_secret_key = "placeholder"

  # Single unit: the default of 3 requires an external PostgreSQL offer
  # (see terraform/cos/variables.tf) that this smoke test doesn't stand up.
  grafana = { units = 1 }
}

# Looked up by name rather than passed as a module output, to avoid a
# dependency cycle with module.seaweedfs below.
data "juju_model" "cos" {
  name  = local.model_name
  owner = "admin"

  depends_on = [module.cos]
}

module "seaweedfs" {
  source     = "../../../../terraform/seaweedfs"
  app_name   = local.seaweedfs_app_name
  model_uuid = data.juju_model.cos.uuid

  depends_on = [module.cos]
}

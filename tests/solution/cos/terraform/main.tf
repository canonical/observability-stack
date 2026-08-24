terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0"
    }
  }
}

resource "juju_model" "cos" {
  name = "cos"
}

# SeaweedFS provides an in-cluster S3-compatible store, avoiding the need for
# external S3 credentials/infrastructure in this smoke test. Its S3 gateway
# uses fixed placeholder credentials (see the seaweedfs-k8s charm source),
# and is reachable at its Juju unit's in-cluster Kubernetes service address.
module "seaweedfs" {
  source     = "../../../../terraform/seaweedfs"
  model_uuid = juju_model.cos.uuid
}

# All other defaults: edge risk, self-signed internal TLS (no external CA
# needed).
module "cos" {
  source     = "../../../../terraform/cos"
  depends_on = [module.seaweedfs]

  model = { uuid = juju_model.cos.uuid }

  s3_endpoint   = "http://${module.seaweedfs.app_name}.cos.svc.cluster.local:8333"
  s3_access_key = "placeholder"
  s3_secret_key = "placeholder"
}

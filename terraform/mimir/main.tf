resource "juju_secret" "mimir_s3_credentials_secret" {
  model = var.model
  name  = "mimir_s3_credentials"
  value = {
    access-key = var.s3_access_key
    secret-key = var.s3_secret_key
  }
  info = "Credentials for the S3 endpoint"
}

resource "juju_access_secret" "mimir_s3_secret_access" {
  model = var.model
  applications = [
    juju_application.s3_integrator.name
  ]
  secret_id = juju_secret.mimir_s3_credentials_secret.secret_id
}

# TODO: Replace s3_integrator resource to use its remote terraform module once available
resource "juju_application" "s3_integrator" {
  config = merge({
    endpoint    = var.s3_endpoint
    bucket      = var.s3_bucket
    credentials = "secret:${juju_secret.mimir_s3_credentials_secret.secret_id}"
  }, var.s3_integrator_config)
  constraints        = var.s3_integrator_constraints
  model              = var.model
  name               = var.s3_integrator_name
  storage_directives = var.s3_integrator_storage_directives
  trust              = true
  units              = var.s3_integrator_units

  charm {
    name     = "s3-integrator"
    channel  = var.s3_integrator_channel
    revision = var.s3_integrator_revision
  }
}

module "mimir_coordinator" {
  source             = "git::https://github.com/canonical/mimir-coordinator-k8s-operator//terraform?ref=tf-provider-v0"
  app_name           = "mimir"
  channel            = var.channel
  config             = var.coordinator_config
  constraints        = var.anti_affinity ? "arch=amd64 tags=anti-pod.app.kubernetes.io/name=mimir,anti-pod.topology-key=kubernetes.io/hostname" : var.coordinator_constraints
  model              = var.model
  revision           = var.coordinator_revision
  storage_directives = var.coordinator_storage_directives
  units              = var.coordinator_units
}

module "mimir_backend" {
  source     = "git::https://github.com/canonical/mimir-worker-k8s-operator//terraform?ref=tf-provider-v0"
  depends_on = [module.mimir_coordinator]

  app_name    = var.backend_name
  channel     = var.channel
  constraints = var.anti_affinity ? "arch=amd64 tags=anti-pod.app.kubernetes.io/name=${var.backend_name},anti-pod.topology-key=kubernetes.io/hostname" : var.worker_constraints
  config = merge({
    role-backend = true
  }, var.backend_config)
  model              = var.model
  revision           = var.worker_revision
  storage_directives = var.worker_storage_directives
  units              = var.backend_units
}

module "mimir_read" {
  source     = "git::https://github.com/canonical/mimir-worker-k8s-operator//terraform?ref=tf-provider-v0"
  depends_on = [module.mimir_coordinator]

  app_name = var.read_name
  channel  = var.channel
  config = merge({
    role-read = true
  }, var.read_config)
  constraints        = var.anti_affinity ? "arch=amd64 tags=anti-pod.app.kubernetes.io/name=${var.read_name},anti-pod.topology-key=kubernetes.io/hostname" : var.worker_constraints
  model              = var.model
  revision           = var.worker_revision
  storage_directives = var.worker_storage_directives
  units              = var.read_units
}

module "mimir_write" {
  source     = "git::https://github.com/canonical/mimir-worker-k8s-operator//terraform?ref=tf-provider-v0"
  depends_on = [module.mimir_coordinator]

  app_name = var.write_name
  channel  = var.channel
  config = merge({
    role-write = true
  }, var.write_config)
  constraints        = var.anti_affinity ? "arch=amd64 tags=anti-pod.app.kubernetes.io/name=${var.write_name},anti-pod.topology-key=kubernetes.io/hostname" : var.worker_constraints
  model              = var.model
  revision           = var.worker_revision
  storage_directives = var.worker_storage_directives
  units              = var.write_units
}

# -------------- # Integrations --------------

resource "juju_integration" "coordinator_to_s3_integrator" {
  model = var.model
  application {
    name     = juju_application.s3_integrator.name
    endpoint = "s3-credentials"
  }

  application {
    name     = module.mimir_coordinator.app_name
    endpoint = "s3"
  }
}

resource "juju_integration" "coordinator_to_read" {
  model = var.model

  application {
    name     = module.mimir_coordinator.app_name
    endpoint = "mimir-cluster"
  }

  application {
    name     = module.mimir_read.app_name
    endpoint = "mimir-cluster"
  }
}

resource "juju_integration" "coordinator_to_write" {
  model = var.model

  application {
    name     = module.mimir_coordinator.app_name
    endpoint = "mimir-cluster"
  }

  application {
    name     = module.mimir_write.app_name
    endpoint = "mimir-cluster"
  }
}

resource "juju_integration" "coordinator_to_backend" {
  model = var.model

  application {
    name     = module.mimir_coordinator.app_name
    endpoint = "mimir-cluster"
  }

  application {
    name     = module.mimir_backend.app_name
    endpoint = "mimir-cluster"
  }
}

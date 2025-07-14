resource "juju_secret" "tempo_s3_credentials_secret" {
  model = var.model
  name  = "tempo_s3_credentials"
  value = {
    access-key = var.s3_access_key
    secret-key = var.s3_secret_key
  }
  info = "Credentials for the S3 endpoint"
}

resource "juju_access_secret" "tempo_s3_secret_access" {
  model = var.model
  applications = [
    juju_application.s3_integrator.name
  ]
  secret_id = juju_secret.tempo_s3_credentials_secret.secret_id
}

# TODO: Replace s3_integrator resource to use its remote terraform module once available
resource "juju_application" "s3_integrator" {
  config = {
    endpoint    = var.s3_endpoint
    bucket      = var.s3_bucket
    credentials = "secret:${juju_secret.tempo_s3_credentials_secret.secret_id}"
  }
  model = var.model
  name  = var.s3_integrator_name
  trust = true
  units = 1

  charm {
    name     = "s3-integrator"
    channel  = var.s3_integrator_channel
    revision = var.s3_integrator_revision
  }
}

module "tempo_coordinator" {
  source = "git::https://github.com/canonical/tempo-coordinator-k8s-operator//terraform"

  channel            = var.channel
  config             = var.coordinator_config
  constraints        = var.anti_affinity ? "arch=amd64 tags=anti-pod.app.kubernetes.io/name=tempo,anti-pod.topology-key=kubernetes.io/hostname" : var.coordinator_constraints
  model              = var.model
  revision           = var.coordinator_revision
  storage_directives = var.coordinator_storage_directives
  units              = var.coordinator_units
}

module "tempo_querier" {
  source     = "git::https://github.com/canonical/tempo-worker-k8s-operator//terraform"
  depends_on = [module.tempo_coordinator]

  app_name = var.querier_name
  channel  = var.channel
  config = merge({
    role-all     = false
    role-querier = true
  }, var.worker_config)
  constraints        = var.anti_affinity ? "arch=amd64 tags=anti-pod.app.kubernetes.io/name=${var.querier_name},anti-pod.topology-key=kubernetes.io/hostname" : var.worker_constraints
  model              = var.model
  revision           = var.worker_revision
  storage_directives = var.worker_storage_directives
  units              = var.querier_units
}

module "tempo_query_frontend" {
  source     = "git::https://github.com/canonical/tempo-worker-k8s-operator//terraform"
  depends_on = [module.tempo_coordinator]

  app_name    = var.query_frontend_name
  model       = var.model
  channel     = var.channel
  constraints = var.anti_affinity ? "arch=amd64 tags=anti-pod.app.kubernetes.io/name=${var.query_frontend_name},anti-pod.topology-key=kubernetes.io/hostname" : var.worker_constraints
  config = merge({
    role-all            = false
    role-query-frontend = true
  }, var.worker_config)
  revision           = var.worker_revision
  storage_directives = var.worker_storage_directives
  units              = var.query_frontend_units
}

module "tempo_ingester" {
  source     = "git::https://github.com/canonical/tempo-worker-k8s-operator//terraform"
  depends_on = [module.tempo_coordinator]

  app_name    = var.ingester_name
  model       = var.model
  channel     = var.channel
  constraints = var.anti_affinity ? "arch=amd64 tags=anti-pod.app.kubernetes.io/name=${var.ingester_name},anti-pod.topology-key=kubernetes.io/hostname" : var.worker_constraints
  config = merge({
    role-all      = false
    role-ingester = true
  }, var.worker_config)
  revision           = var.worker_revision
  storage_directives = var.worker_storage_directives
  units              = var.ingester_units
}

module "tempo_distributor" {
  source     = "git::https://github.com/canonical/tempo-worker-k8s-operator//terraform"
  depends_on = [module.tempo_coordinator]

  app_name    = var.distributor_name
  model       = var.model
  channel     = var.channel
  constraints = var.anti_affinity ? "arch=amd64 tags=anti-pod.app.kubernetes.io/name=${var.distributor_name},anti-pod.topology-key=kubernetes.io/hostname" : var.worker_constraints
  config = merge({
    role-all         = false
    role-distributor = true
  }, var.worker_config)
  revision           = var.worker_revision
  storage_directives = var.worker_storage_directives
  units              = var.distributor_units
}

module "tempo_compactor" {
  source     = "git::https://github.com/canonical/tempo-worker-k8s-operator//terraform"
  depends_on = [module.tempo_coordinator]

  app_name    = var.compactor_name
  model       = var.model
  channel     = var.channel
  constraints = var.anti_affinity ? "arch=amd64 tags=anti-pod.app.kubernetes.io/name=${var.compactor_name},anti-pod.topology-key=kubernetes.io/hostname" : var.worker_constraints
  config = merge({
    role-all       = false
    role-compactor = true
  }, var.worker_config)
  revision           = var.worker_revision
  storage_directives = var.worker_storage_directives
  units              = var.compactor_units
}

module "tempo_metrics_generator" {
  source     = "git::https://github.com/canonical/tempo-worker-k8s-operator//terraform"
  depends_on = [module.tempo_coordinator]

  app_name    = var.metrics_generator_name
  model       = var.model
  channel     = var.channel
  constraints = var.anti_affinity ? "arch=amd64 tags=anti-pod.app.kubernetes.io/name=${var.metrics_generator_name},anti-pod.topology-key=kubernetes.io/hostname" : var.worker_constraints
  config = merge({
    role-all               = false
    role-metrics-generator = true
  }, var.worker_config)
  revision           = var.worker_revision
  storage_directives = var.worker_storage_directives
  units              = var.metrics_generator_units
}

# -------------- # Integrations --------------

resource "juju_integration" "coordinator_to_s3_integrator" {
  model = var.model

  application {
    name     = juju_application.s3_integrator.name
    endpoint = "s3-credentials"
  }

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "s3"
  }
}

resource "juju_integration" "coordinator_to_querier" {
  model = var.model

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "tempo-cluster"
  }

  application {
    name     = module.tempo_querier.app_name
    endpoint = "tempo-cluster"
  }
}

resource "juju_integration" "coordinator_to_query_frontend" {
  model = var.model

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "tempo-cluster"
  }

  application {
    name     = module.tempo_query_frontend.app_name
    endpoint = "tempo-cluster"
  }
}

resource "juju_integration" "coordinator_to_ingester" {
  model = var.model

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "tempo-cluster"
  }

  application {
    name     = module.tempo_ingester.app_name
    endpoint = "tempo-cluster"
  }
}

resource "juju_integration" "coordinator_to_distributor" {
  model = var.model

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "tempo-cluster"
  }

  application {
    name     = module.tempo_distributor.app_name
    endpoint = "tempo-cluster"
  }
}

resource "juju_integration" "coordinator_to_compactor" {
  model = var.model

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "tempo-cluster"
  }

  application {
    name     = module.tempo_compactor.app_name
    endpoint = "tempo-cluster"
  }
}

resource "juju_integration" "coordinator_to_metrics_generator" {
  model = var.model

  application {
    name     = module.tempo_coordinator.app_name
    endpoint = "tempo-cluster"
  }

  application {
    name     = module.tempo_metrics_generator.app_name
    endpoint = "tempo-cluster"
  }
}

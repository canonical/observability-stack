mock_provider "juju" {}

variables {
  model_uuid = "00000000-0000-0000-0000-000000000000"
}

# --- Default: monolithic topology with seaweedfs ---

run "default_monolithic_seaweedfs" {
  command = plan

  assert {
    condition     = length(module.seaweedfs) == 1
    error_message = "Expected seaweedfs module to be deployed with seaweedfs storage backend"
  }

  assert {
    condition     = length(module.loki_worker) == 1
    error_message = "Expected monolithic loki_worker to be deployed"
  }

  assert {
    condition     = length(module.mimir_worker) == 1
    error_message = "Expected monolithic mimir_worker to be deployed"
  }

  assert {
    condition     = length(module.tempo_worker) == 1
    error_message = "Expected monolithic tempo_worker to be deployed"
  }

  assert {
    condition     = length(module.loki_worker_backend) == 0
    error_message = "Expected no distributed loki_worker_backend in monolithic mode"
  }

  assert {
    condition     = length(module.mimir_worker_backend) == 0
    error_message = "Expected no distributed mimir_worker_backend in monolithic mode"
  }

  assert {
    condition     = length(module.tempo_worker_ingester) == 0
    error_message = "Expected no distributed tempo_worker_ingester in monolithic mode"
  }

  assert {
    condition     = length(juju_integration.seaweedfs_loki) == 1
    error_message = "Expected seaweedfs_loki integration in seaweedfs mode"
  }

  assert {
    condition     = length(juju_integration.seaweedfs_mimir) == 1
    error_message = "Expected seaweedfs_mimir integration in seaweedfs mode"
  }

  assert {
    condition     = length(juju_integration.seaweedfs_tempo) == 1
    error_message = "Expected seaweedfs_tempo integration in seaweedfs mode"
  }

  assert {
    condition     = length(juju_integration.loki_cluster) == 1
    error_message = "Expected monolithic loki_cluster integration"
  }

  assert {
    condition     = length(juju_integration.loki_cluster_backend) == 0
    error_message = "Expected no distributed loki_cluster_backend integration in monolithic mode"
  }
}

# --- Distributed topology with seaweedfs ---

run "distributed_seaweedfs" {
  command = plan

  variables {
    topology = "distributed"
  }

  assert {
    condition     = length(module.seaweedfs) == 1
    error_message = "Expected seaweedfs module to be deployed with seaweedfs storage backend"
  }

  assert {
    condition     = length(module.loki_worker) == 0
    error_message = "Expected no monolithic loki_worker in distributed mode"
  }

  assert {
    condition     = length(module.loki_worker_backend) == 1
    error_message = "Expected distributed loki_worker_backend in distributed mode"
  }

  assert {
    condition     = length(module.loki_worker_read) == 1
    error_message = "Expected distributed loki_worker_read in distributed mode"
  }

  assert {
    condition     = length(module.loki_worker_write) == 1
    error_message = "Expected distributed loki_worker_write in distributed mode"
  }

  assert {
    condition     = length(module.mimir_worker_backend) == 1
    error_message = "Expected distributed mimir_worker_backend in distributed mode"
  }

  assert {
    condition     = length(module.tempo_worker_querier) == 1
    error_message = "Expected distributed tempo_worker_querier in distributed mode"
  }

  assert {
    condition     = length(module.tempo_worker_query_frontend) == 1
    error_message = "Expected distributed tempo_worker_query_frontend in distributed mode"
  }

  assert {
    condition     = length(module.tempo_worker_ingester) == 1
    error_message = "Expected distributed tempo_worker_ingester in distributed mode"
  }

  assert {
    condition     = length(module.tempo_worker_distributor) == 1
    error_message = "Expected distributed tempo_worker_distributor in distributed mode"
  }

  assert {
    condition     = length(module.tempo_worker_compactor) == 1
    error_message = "Expected distributed tempo_worker_compactor in distributed mode"
  }

  assert {
    condition     = length(module.tempo_worker_metrics_generator) == 1
    error_message = "Expected distributed tempo_worker_metrics_generator in distributed mode"
  }

  assert {
    condition     = length(juju_integration.seaweedfs_loki) == 1
    error_message = "Expected seaweedfs_loki integration in seaweedfs mode"
  }

  assert {
    condition     = length(juju_integration.loki_cluster) == 0
    error_message = "Expected no monolithic loki_cluster integration in distributed mode"
  }

  assert {
    condition     = length(juju_integration.loki_cluster_backend) == 1
    error_message = "Expected distributed loki_cluster_backend integration"
  }

  assert {
    condition     = length(juju_integration.loki_cluster_read) == 1
    error_message = "Expected distributed loki_cluster_read integration"
  }

  assert {
    condition     = length(juju_integration.loki_cluster_write) == 1
    error_message = "Expected distributed loki_cluster_write integration"
  }

  assert {
    condition     = length(juju_integration.mimir_cluster_backend) == 1
    error_message = "Expected distributed mimir_cluster_backend integration"
  }

  assert {
    condition     = length(juju_integration.tempo_cluster_ingester) == 1
    error_message = "Expected distributed tempo_cluster_ingester integration"
  }
}

# --- Monolithic topology with s3-integrator ---

run "monolithic_s3" {
  command = plan

  variables {
    storage_backend = "s3"
    s3_endpoint     = "https://s3.example.com"
    s3_access_key   = "access-key"
    s3_secret_key   = "secret-key"
    loki_bucket     = "loki"
    mimir_bucket    = "mimir"
    tempo_bucket    = "tempo"
  }

  assert {
    condition     = length(module.seaweedfs) == 0
    error_message = "Expected no seaweedfs module with s3 storage backend"
  }

  assert {
    condition     = length(module.loki_worker) == 1
    error_message = "Expected monolithic loki_worker in monolithic mode"
  }

  assert {
    condition     = length(juju_application.s3_integrator_loki) == 1
    error_message = "Expected s3_integrator_loki application in s3 mode"
  }

  assert {
    condition     = length(juju_application.s3_integrator_mimir) == 1
    error_message = "Expected s3_integrator_mimir application in s3 mode"
  }

  assert {
    condition     = length(juju_application.s3_integrator_tempo) == 1
    error_message = "Expected s3_integrator_tempo application in s3 mode"
  }

  assert {
    condition     = length(juju_integration.s3_integrator_loki) == 1
    error_message = "Expected s3_integrator_loki integration in s3 mode"
  }

  assert {
    condition     = length(juju_integration.s3_integrator_mimir) == 1
    error_message = "Expected s3_integrator_mimir integration in s3 mode"
  }

  assert {
    condition     = length(juju_integration.s3_integrator_tempo) == 1
    error_message = "Expected s3_integrator_tempo integration in s3 mode"
  }

  assert {
    condition     = length(juju_integration.seaweedfs_loki) == 0
    error_message = "Expected no seaweedfs_loki integration with s3 storage backend"
  }
}

# --- Distributed topology with s3-integrator ---

run "distributed_s3" {
  command = plan

  variables {
    topology        = "distributed"
    storage_backend = "s3"
    s3_endpoint     = "https://s3.example.com"
    s3_access_key   = "access-key"
    s3_secret_key   = "secret-key"
    loki_bucket     = "loki"
    mimir_bucket    = "mimir"
    tempo_bucket    = "tempo"
  }

  assert {
    condition     = length(module.seaweedfs) == 0
    error_message = "Expected no seaweedfs module with s3 storage backend"
  }

  assert {
    condition     = length(module.loki_worker) == 0
    error_message = "Expected no monolithic loki_worker in distributed mode"
  }

  assert {
    condition     = length(module.loki_worker_backend) == 1
    error_message = "Expected distributed loki_worker_backend in distributed mode"
  }

  assert {
    condition     = length(juju_application.s3_integrator_loki) == 1
    error_message = "Expected s3_integrator_loki application in s3 mode"
  }

  assert {
    condition     = length(juju_integration.s3_integrator_loki) == 1
    error_message = "Expected s3_integrator_loki integration in s3 mode"
  }

  assert {
    condition     = length(juju_integration.seaweedfs_loki) == 0
    error_message = "Expected no seaweedfs_loki integration with s3 storage backend"
  }

  assert {
    condition     = length(juju_integration.loki_cluster_backend) == 1
    error_message = "Expected distributed loki_cluster_backend integration"
  }
}

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
    condition = alltrue([
      length(juju_integration.seaweedfs_loki) == 1,
      length(juju_integration.seaweedfs_mimir) == 1,
      length(juju_integration.seaweedfs_tempo) == 1,
    ])
    error_message = "Expected seaweedfs integrations to all coordinators"
  }

  assert {
    condition = alltrue([
      length(module.loki_worker) == 1,
      length(module.mimir_worker) == 1,
      length(module.tempo_worker) == 1,
    ])
    error_message = "Expected all monolithic workers to be deployed"
  }

  assert {
    condition = !anytrue([
      length(module.loki_worker_backend) > 0,
      length(module.loki_worker_read) > 0,
      length(module.loki_worker_write) > 0,
    ])
    error_message = "Expected no distributed loki workers in monolithic mode"
  }

  assert {
    condition = !anytrue([
      length(module.mimir_worker_backend) > 0,
      length(module.mimir_worker_read) > 0,
      length(module.mimir_worker_write) > 0,
    ])
    error_message = "Expected no distributed mimir workers in monolithic mode"
  }

  assert {
    condition = !anytrue([
      length(module.tempo_worker_querier) > 0,
      length(module.tempo_worker_query_frontend) > 0,
      length(module.tempo_worker_ingester) > 0,
      length(module.tempo_worker_distributor) > 0,
      length(module.tempo_worker_compactor) > 0,
      length(module.tempo_worker_metrics_generator) > 0,
    ])
    error_message = "Expected no distributed tempo workers in monolithic mode"
  }

  assert {
    condition = alltrue([
      length(juju_integration.loki_cluster) == 1,
      length(juju_integration.mimir_cluster) == 1,
      length(juju_integration.tempo_cluster) == 1,
    ])
    error_message = "Expected monolithic cluster integrations for all coordinators"
  }

  assert {
    condition = !anytrue([
      length(juju_integration.loki_cluster_backend) > 0,
      length(juju_integration.loki_cluster_read) > 0,
      length(juju_integration.loki_cluster_write) > 0,
    ])
    error_message = "Expected no distributed loki cluster integrations in monolithic mode"
  }

  assert {
    condition = !anytrue([
      length(juju_integration.mimir_cluster_backend) > 0,
      length(juju_integration.mimir_cluster_read) > 0,
      length(juju_integration.mimir_cluster_write) > 0,
    ])
    error_message = "Expected no distributed mimir cluster integrations in monolithic mode"
  }

  assert {
    condition = !anytrue([
      length(juju_integration.tempo_cluster_querier) > 0,
      length(juju_integration.tempo_cluster_query_frontend) > 0,
      length(juju_integration.tempo_cluster_ingester) > 0,
      length(juju_integration.tempo_cluster_distributor) > 0,
      length(juju_integration.tempo_cluster_compactor) > 0,
      length(juju_integration.tempo_cluster_metrics_generator) > 0,
    ])
    error_message = "Expected no distributed tempo cluster integrations in monolithic mode"
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
    condition = alltrue([
      length(juju_integration.seaweedfs_loki) == 1,
      length(juju_integration.seaweedfs_mimir) == 1,
      length(juju_integration.seaweedfs_tempo) == 1,
    ])
    error_message = "Expected seaweedfs integrations to all coordinators"
  }

  assert {
    condition = !anytrue([
      length(module.loki_worker) > 0,
      length(module.mimir_worker) > 0,
      length(module.tempo_worker) > 0,
    ])
    error_message = "Expected no monolithic workers in distributed mode"
  }

  assert {
    condition = alltrue([
      length(module.loki_worker_backend) == 1,
      length(module.loki_worker_read) == 1,
      length(module.loki_worker_write) == 1,
    ])
    error_message = "Expected all distributed loki workers (backend, read, write)"
  }

  assert {
    condition = alltrue([
      length(module.mimir_worker_backend) == 1,
      length(module.mimir_worker_read) == 1,
      length(module.mimir_worker_write) == 1,
    ])
    error_message = "Expected all distributed mimir workers (backend, read, write)"
  }

  assert {
    condition = alltrue([
      length(module.tempo_worker_querier) == 1,
      length(module.tempo_worker_query_frontend) == 1,
      length(module.tempo_worker_ingester) == 1,
      length(module.tempo_worker_distributor) == 1,
      length(module.tempo_worker_compactor) == 1,
      length(module.tempo_worker_metrics_generator) == 1,
    ])
    error_message = "Expected all distributed tempo workers (querier, query_frontend, ingester, distributor, compactor, metrics_generator)"
  }

  assert {
    condition = !anytrue([
      length(juju_integration.loki_cluster) > 0,
      length(juju_integration.mimir_cluster) > 0,
      length(juju_integration.tempo_cluster) > 0,
    ])
    error_message = "Expected no monolithic cluster integrations in distributed mode"
  }

  assert {
    condition = alltrue([
      length(juju_integration.loki_cluster_backend) == 1,
      length(juju_integration.loki_cluster_read) == 1,
      length(juju_integration.loki_cluster_write) == 1,
    ])
    error_message = "Expected all distributed loki cluster integrations (backend, read, write)"
  }

  assert {
    condition = alltrue([
      length(juju_integration.mimir_cluster_backend) == 1,
      length(juju_integration.mimir_cluster_read) == 1,
      length(juju_integration.mimir_cluster_write) == 1,
    ])
    error_message = "Expected all distributed mimir cluster integrations (backend, read, write)"
  }

  assert {
    condition = alltrue([
      length(juju_integration.tempo_cluster_querier) == 1,
      length(juju_integration.tempo_cluster_query_frontend) == 1,
      length(juju_integration.tempo_cluster_ingester) == 1,
      length(juju_integration.tempo_cluster_distributor) == 1,
      length(juju_integration.tempo_cluster_compactor) == 1,
      length(juju_integration.tempo_cluster_metrics_generator) == 1,
    ])
    error_message = "Expected all distributed tempo cluster integrations"
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
    condition = alltrue([
      length(juju_application.s3_integrator_loki) == 1,
      length(juju_application.s3_integrator_mimir) == 1,
      length(juju_application.s3_integrator_tempo) == 1,
    ])
    error_message = "Expected s3-integrator applications for all coordinators"
  }

  assert {
    condition = alltrue([
      length(juju_integration.s3_integrator_loki) == 1,
      length(juju_integration.s3_integrator_mimir) == 1,
      length(juju_integration.s3_integrator_tempo) == 1,
    ])
    error_message = "Expected s3-integrator integrations for all coordinators"
  }

  assert {
    condition = !anytrue([
      length(juju_integration.seaweedfs_loki) > 0,
      length(juju_integration.seaweedfs_mimir) > 0,
      length(juju_integration.seaweedfs_tempo) > 0,
    ])
    error_message = "Expected no seaweedfs integrations with s3 storage backend"
  }

  assert {
    condition = alltrue([
      length(module.loki_worker) == 1,
      length(module.mimir_worker) == 1,
      length(module.tempo_worker) == 1,
    ])
    error_message = "Expected all monolithic workers in monolithic mode"
  }

  assert {
    condition = !anytrue([
      length(module.loki_worker_backend) > 0,
      length(module.loki_worker_read) > 0,
      length(module.loki_worker_write) > 0,
      length(module.mimir_worker_backend) > 0,
      length(module.mimir_worker_read) > 0,
      length(module.mimir_worker_write) > 0,
      length(module.tempo_worker_querier) > 0,
      length(module.tempo_worker_query_frontend) > 0,
      length(module.tempo_worker_ingester) > 0,
      length(module.tempo_worker_distributor) > 0,
      length(module.tempo_worker_compactor) > 0,
      length(module.tempo_worker_metrics_generator) > 0,
    ])
    error_message = "Expected no distributed workers in monolithic mode"
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
    condition = alltrue([
      length(juju_application.s3_integrator_loki) == 1,
      length(juju_application.s3_integrator_mimir) == 1,
      length(juju_application.s3_integrator_tempo) == 1,
    ])
    error_message = "Expected s3-integrator applications for all coordinators"
  }

  assert {
    condition = alltrue([
      length(juju_integration.s3_integrator_loki) == 1,
      length(juju_integration.s3_integrator_mimir) == 1,
      length(juju_integration.s3_integrator_tempo) == 1,
    ])
    error_message = "Expected s3-integrator integrations for all coordinators"
  }

  assert {
    condition = !anytrue([
      length(juju_integration.seaweedfs_loki) > 0,
      length(juju_integration.seaweedfs_mimir) > 0,
      length(juju_integration.seaweedfs_tempo) > 0,
    ])
    error_message = "Expected no seaweedfs integrations with s3 storage backend"
  }

  assert {
    condition = !anytrue([
      length(module.loki_worker) > 0,
      length(module.mimir_worker) > 0,
      length(module.tempo_worker) > 0,
    ])
    error_message = "Expected no monolithic workers in distributed mode"
  }

  assert {
    condition = alltrue([
      length(module.loki_worker_backend) == 1,
      length(module.loki_worker_read) == 1,
      length(module.loki_worker_write) == 1,
    ])
    error_message = "Expected all distributed loki workers (backend, read, write)"
  }

  assert {
    condition = alltrue([
      length(module.mimir_worker_backend) == 1,
      length(module.mimir_worker_read) == 1,
      length(module.mimir_worker_write) == 1,
    ])
    error_message = "Expected all distributed mimir workers (backend, read, write)"
  }

  assert {
    condition = alltrue([
      length(module.tempo_worker_querier) == 1,
      length(module.tempo_worker_query_frontend) == 1,
      length(module.tempo_worker_ingester) == 1,
      length(module.tempo_worker_distributor) == 1,
      length(module.tempo_worker_compactor) == 1,
      length(module.tempo_worker_metrics_generator) == 1,
    ])
    error_message = "Expected all distributed tempo workers"
  }

  assert {
    condition = !anytrue([
      length(juju_integration.loki_cluster) > 0,
      length(juju_integration.mimir_cluster) > 0,
      length(juju_integration.tempo_cluster) > 0,
    ])
    error_message = "Expected no monolithic cluster integrations in distributed mode"
  }

  assert {
    condition = alltrue([
      length(juju_integration.loki_cluster_backend) == 1,
      length(juju_integration.loki_cluster_read) == 1,
      length(juju_integration.loki_cluster_write) == 1,
    ])
    error_message = "Expected all distributed loki cluster integrations"
  }

  assert {
    condition = alltrue([
      length(juju_integration.mimir_cluster_backend) == 1,
      length(juju_integration.mimir_cluster_read) == 1,
      length(juju_integration.mimir_cluster_write) == 1,
    ])
    error_message = "Expected all distributed mimir cluster integrations"
  }

  assert {
    condition = alltrue([
      length(juju_integration.tempo_cluster_querier) == 1,
      length(juju_integration.tempo_cluster_query_frontend) == 1,
      length(juju_integration.tempo_cluster_ingester) == 1,
      length(juju_integration.tempo_cluster_distributor) == 1,
      length(juju_integration.tempo_cluster_compactor) == 1,
      length(juju_integration.tempo_cluster_metrics_generator) == 1,
    ])
    error_message = "Expected all distributed tempo cluster integrations"
  }
}

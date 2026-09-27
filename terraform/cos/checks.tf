# -------------- # Storage directives for storage-intensive components --------------

check "grafana_storage_directives" {
  assert {
    condition     = local.grafana_db_enabled || length(var.grafana.storage_directives) > 0
    error_message = "grafana.storage_directives ${local.storage_directives_warning}"
  }
}

check "loki_worker_write_storage_directives" {
  assert {
    condition     = length(var.loki_worker.write_storage_directives) > 0
    error_message = "loki_worker.write_storage_directives ${local.storage_directives_warning}"
  }
}

check "mimir_worker_write_storage_directives" {
  assert {
    condition     = length(var.mimir_worker.write_storage_directives) > 0
    error_message = "mimir_worker.write_storage_directives ${local.storage_directives_warning}"
  }
}

check "mimir_worker_backend_storage_directives" {
  assert {
    condition     = length(var.mimir_worker.backend_storage_directives) > 0
    error_message = "mimir_worker.backend_storage_directives ${local.storage_directives_warning}"
  }
}

check "tempo_worker_ingester_storage_directives" {
  assert {
    condition     = length(var.tempo_worker.ingester_worker_storage_directives) > 0
    error_message = "tempo_worker.ingester_worker_storage_directives ${local.storage_directives_warning}"
  }
}

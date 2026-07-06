# -------------- # Storage directives for storage-intensive components --------------

check "grafana_storage_directives" {
  assert {
    condition     = length(var.grafana.storage_directives) > 0
    error_message = "grafana.storage_directives ${local.storage_directives_warning}"
  }
}

check "loki_storage_directives" {
  assert {
    condition     = length(var.loki.storage_directives) > 0
    error_message = "loki.storage_directives ${local.storage_directives_warning}"
  }
}

check "prometheus_storage_directives" {
  assert {
    condition     = length(var.prometheus.storage_directives) > 0
    error_message = "prometheus.storage_directives ${local.storage_directives_warning}"
  }
}

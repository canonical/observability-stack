# Non-blocking, plan-time warnings.

# Storage directives for storage-intensive components
# We only assert that a storage size was *chosen* (the map is non-empty). We
# deliberately do not police whether the chosen size is large enough: that
# depends on retention, ingest rate, and replication, which Terraform cannot
# know. See the storage guide for sizing guidance:
# https://documentation.ubuntu.com/observability/latest/how-to/configure-and-tune/customize-storage-options/
check "storage_directives_configured" {
  assert {
    condition     = length(var.alertmanager.storage_directives) > 0
    error_message = "alertmanager.storage_directives is unset, so it will use the default 1G volume. Set a size before deploying to production; resizing a persistent volume after deployment requires manual steps. See https://documentation.ubuntu.com/observability/latest/how-to/configure-and-tune/customize-storage-options/"
  }

  assert {
    condition     = length(var.loki.storage_directives) > 0
    error_message = "loki.storage_directives is unset, so it will use the default 1G volume. Set a size before deploying to production; resizing a persistent volume after deployment requires manual steps. See https://documentation.ubuntu.com/observability/latest/how-to/configure-and-tune/customize-storage-options/"
  }

  assert {
    condition     = length(var.prometheus.storage_directives) > 0
    error_message = "prometheus.storage_directives is unset, so it will use the default 1G volume. Set a size before deploying to production; resizing a persistent volume after deployment requires manual steps. See https://documentation.ubuntu.com/observability/latest/how-to/configure-and-tune/customize-storage-options/"
  }
}

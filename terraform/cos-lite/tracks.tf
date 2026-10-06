locals {
  bases = {
    o11y    = "ubuntu@26.04"
    ssc     = "ubuntu@24.04"
    traefik = "ubuntu@26.04"
  }
  tracks = {
    alertmanager = "dev"
    catalogue    = "dev"
    grafana      = "dev"
    loki         = "dev"
    otelcol      = "dev"
    prometheus   = "dev"
    # external charms
    ssc     = "1"
    traefik = "latest"
  }
}

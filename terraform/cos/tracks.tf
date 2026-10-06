locals {
  bases = {
    o11y          = "ubuntu@26.04"
    s3_integrator = "ubuntu@24.04"
    ssc           = "ubuntu@24.04"
    traefik       = "ubuntu@26.04"
  }
  tracks = {
    alertmanager = "dev"
    catalogue    = "dev"
    grafana      = "dev"
    loki         = "dev"
    mimir        = "dev"
    otelcol      = "dev"
    tempo        = "dev"
    # external charms
    s3_integrator = "2"
    ssc           = "1"
    traefik       = "latest"
  }
}

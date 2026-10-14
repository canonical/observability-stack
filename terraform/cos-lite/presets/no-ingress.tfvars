# Disable ingress (and Traefik) for every COS component.

ingress = {
  alertmanager            = false
  catalogue               = false
  grafana                 = false
  loki                    = false
  prometheus              = false
  opentelemetry_collector = false
}

# Disable ingress (and Traefik) for every COS Lite component.

ingress = {
  alertmanager            = false
  catalogue               = false
  grafana                 = false
  loki                    = false
  opentelemetry_collector = false
  prometheus              = false
}

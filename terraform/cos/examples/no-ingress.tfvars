# Disable ingress for every COS component.

ingress = {
  alertmanager            = false
  catalogue               = false
  grafana                 = false
  loki                    = false
  mimir                   = false
  opentelemetry_collector = false
  tempo                   = false
}

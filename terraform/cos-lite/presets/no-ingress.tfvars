# Disable ingress for every COS component and the ingress provider app.

ingress = {
  alertmanager            = false
  catalogue               = false
  grafana                 = false
  loki                    = false
  mimir                   = false
  opentelemetry_collector = false
  tempo                   = false
}

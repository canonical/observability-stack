# Migrate from Grafana Agent to OpenTelemetry Collector

These are the steps to follow:

1. deploy the collector next to the agent charm
2. look at the relations for grafana-agent, and replicate them for the collector
  - note that some relation endpoints have slightly different names, for clarity:
    - `logging-consumer` is now `send-loki-logs`
    - `grafana-cloud-config` is now `cloud-config`
3. verify that data is appearing in the backends (Mimir, Prometheus, Loki, etc.)
4. remove grafana-agent from your deployment

## Known Issues

Unlike `grafana-agent`, OpenTelemetry Collector maintains state in-memory by default: this means that queued telemetry data will be lost on restart. This will be addressed in the future with the **File Storage extension**, tracked in [opentelemetry-collector-k8s#34](https://github.com/canonical/opentelemetry-collector-k8s-operator/issues/34).

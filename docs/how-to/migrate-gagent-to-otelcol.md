# Migrate from Grafana Agent to OpenTelemetry Collector
> Grafana Agent has reached End-of-Life (EOL) on November 1, 2025.
Grafana Agent is no longer receiving support, security, or bug fixes from the vendor. Since it is part of COS, the charmed operators for Grafana Agent will continue to  receive bug fixes until July 2026. You should plan to migrate from charmed Grafana Agent to charmed Opentelemetry Collector before that date.  

These are the steps to follow:

1. Ensure you are using Juju 3.6.
1. Deploy the collector next to the agent charm
1. Look at the relations for grafana-agent, and replicate them for the collector
    - Note that some relation endpoints have slightly different names, for clarity:
      - `logging-consumer` is now `send-loki-logs`
      - `grafana-cloud-config` is now `cloud-config`
1. Verify that data is appearing in the backends (Mimir, Prometheus, Loki, etc.)
1. Remove grafana-agent from your deployment


## Known Issues

Unlike `grafana-agent`, OpenTelemetry Collector maintains state in-memory by default: this means that queued telemetry data will be lost on restart. This will be addressed in the future with the **File Storage extension**, tracked in [opentelemetry-collector-k8s#34](https://github.com/canonical/opentelemetry-collector-k8s-operator/issues/34).

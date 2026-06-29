# Monitor SSL Certificates with Blackbox Exporter

This guide shows how to configure Blackbox Exporter to monitor SSL certificate
expiry and surface the results in Grafana dashboards and Alertmanager
notifications.

This guide makes use of the following charms:

- [`blackbox-exporter-k8s`](https://charmhub.io/blackbox-exporter-k8s). This will produce the `probe_ssl_earliest_cert_expiry` metric, which is the "last SSL chain expiry in unix time".
- [`prometheus-k8s`](https://charmhub.io/prometheus-k8s)
- [`grafana-k8s`](https://charmhub.io/grafana-k8s)
- [`alertmanager-k8s`](https://charmhub.io/alertmanager-k8s)

## Prerequisites

- A Juju Kubernetes controller

## Deploy blackbox exporter

```bash
juju add-model tutorial-blackbox
juju deploy blackbox-exporter-k8s blackbox --trust
```

## Configure SSL probes

Create a scrape configuration file listing the HTTPS endpoints to monitor:

```yaml
--- # probes.yaml
scrape_configs:
  - job_name: "tutorial-blackbox"
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - https://canonical.com
          - https://ubuntu.com
          - https://juju.is
          - https://charmhub.io
          - https://discourse.charmhub.io
          - https://snapcraft.io
```

Apply the configuration to Blackbox Exporter:

```bash
juju config blackbox probes_file='@probes.yaml'
```

## Integrate with Prometheus

Connect Blackbox Exporter to Prometheus so the probes are scraped, then connect
Prometheus to Grafana and Alertmanager:

```bash
juju deploy prometheus-k8s prometheus --trust
juju relate blackbox prometheus:metrics-endpoint
```

### Check metrics in Prometheus

Navigate to the Prometheus UI (port 9090). After Prometheus scrapes Blackbox
Exporter for the first time (up to 60 seconds), query
`probe_ssl_earliest_cert_expiry` to confirm the data is flowing.

![image|690x263](/assets/prometheus_probe_ssl_earliest_cert_expiry.png)

## Integrate with Grafana and Alertmanager

```bash
# Deploy the remaining charms
juju deploy grafana-k8s grafana --trust
juju deploy alertmanager-k8s alertmanager --trust

# Create the necessary relations
juju relate prometheus:grafana-source grafana  # Use and configure Prometheus as a datasource in Grafana
juju relate prometheus:alertmanager alertmanager  # Alertmanager can fire notifications when an alert is triggered in Prometheus
juju relate blackbox:grafana-dashboard grafana  # Send the dashboards bundled in Blackbox Exporter to Grafana
```

### Review alerts in Alertmanager

Navigate to the Alertmanager UI (port 9093). Blackbox Exporter ships built-in
alert rules that fire:

- A **warning** when a certificate expires in less than 30 days.
- A **critical** alert when a certificate expires in less than 15 days.

![image|690x353](/assets/alertmanager_BlackboxExporterSSLCertExpiringSoon30Days.png)

To add custom alert rules, use the
[`cos-configuration-k8s`](https://charmhub.io/cos-configuration-k8s) charm.

### Review dashboard in Grafana

1. Retrieve the admin password:

   ```bash
   juju run grafana/leader get-admin-password
   ```

2. Navigate to Grafana (port 3000) and log in as `admin`.

3. Use the sidebar to open the **Blackbox Exporter** dashboard under the
   **General** folder. The SSL panel shows certificate expiry data in a
   sortable table — click the **Certificate Validity** column header to
   identify certificates expiring soonest.

![image|690x320](/assets/grafana_ssl_probes.png)

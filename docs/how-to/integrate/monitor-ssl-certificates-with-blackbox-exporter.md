# Monitor SSL Certificates with Blackbox Exporter

You want to _observe_ your SSL Certificates but don't know how?

This tutorial will teach you to:

- monitor your certificates from a cool Grafana dashboard;
- get alerts when your certificates are about to expire.

## Tools

All we need to get started is a few Observability charms. Let's go through them.

**Blackbox Exporter** ([blackbox-exporter-k8s](https://charmhub.io/blackbox-exporter-k8s)) is a Prometheus exporter that allows running different kinds of probes (e.g., HTTP, HTTPS, DNS, TCP, ICMP, etc.). When a probe is executed, the exporter returns its results in a metrics page, which can be scraped by Prometheus.
Different probes produce different information: running HTTPS probes gives insights on the SSL certificate expiration time with the `probe_ssl_earliest_cert_expiry` metric, which is the “last SSL chain expiry in unixtime” ([source](https://github.com/prometheus/blackbox_exporter/blob/b1a4a58dad5f8f8684f38c80162411eedf5c2b31/prober/prober.go#L28C43-L28C76)).

**Prometheus** ([prometheus-k8s](https://charmhub.io/prometheus-k8s)) collects and stores metrics as time series data. We will configure it to periodically run the Blackbox Exporter probes.

**Alertmanager** ([alertmanager-k8s](https://charmhub.io/alertmanager-k8s)) fires alerts and notifies us when the SSL certificates we're monitoring are about to expire.

**Grafana** ([grafana-k8s](https://charmhub.io/grafana-k8s)) allows us to visualize the information in fancy dashboards.

## Step-by-step process

### Set up the probes

Start by creating a model (on a Kubernetes controller) for this tutorial, and deploy the Blackbox Exporter.

```bash
juju add-model tutorial-blackbox
juju deploy blackbox-exporter-k8s blackbox --trust
```

You can read a thorough explanation of how to use Blackbox Exporter in our [documentation](https://charmhub.io/blackbox-exporter-k8s/docs/using). For the purpose of this tutorial, we need to create a configuration file (which we'll call `probes.yaml`) that specifies which _HTTPS_ endpoints should be probed, and then pass it to the exporter.

```yaml
--- # probes.yaml
scrape_configs:
  - job_name: "tutorial-blackbox" # anything you want
    metrics_path: /probe
    params:
      module: [http_2xx] # Look for a HTTP 200 response.
    static_configs:
      - targets: # List of HTTPS endpoints to observe
          - https://canonical.com
          - https://ubuntu.com
          - https://juju.is
          - https://charmhub.io
          - https://discourse.charmhub.io
          - https://snapcraft.io
```

Pass the entire file to the Blackbox Exporter charm via `juju config`:

```bash
juju config blackbox probes_file='@probes.yaml'
```

To have Prometheus execute the probes, simply deploy it and relate it to Blackbox Exporter:

```bash
juju deploy prometheus-k8s prometheus --trust
juju relate blackbox prometheus:metrics-endpoint
```

You can now navigate to the Prometheus url (on port 9090) and, after waiting for at least 60 seconds for Prometheus to scrape the exporter for the first time, you'll be able to type `probe_ssl_earliest_cert_expiry` and see the data in Prometheus.

![image|690x263](/assets/prometheus_probe_ssl_earliest_cert_expiry.png)

But this raw data is not useful on its own: let's leverage the integrations with Grafana and Alertmanager to get some insights on the certificates we want to observe.

### Utilize the data

Dashboard and alert rules are automatically bundled with the Blackbox Exporter charm. All we need to do is deploy Grafana and Alertmanager, then wire everything up.

```bash
# Deploy the remaining charms
juju deploy grafana-k8s grafana --trust
juju deploy alertmanager-k8s alertmanager --trust

# Create the necessary relations
juju relate prometheus:grafana-source grafana  # Use and configure Prometheus as a datasource in Grafana
juju relate prometheus:alertmanager alertmanager  # Alertmanager can fire notifications when an alert is triggered in Prometheus
juju relate blackbox:grafana-dashboard grafana  # Send the dashboards bundled in Blackbox Exporter to Grafana
```

#### Check the alerts in Alertmanager

Navigate to the Alertmanager UI (on port 9093). You'll see the alerts that Blackbox Exporter is sending to Prometheus over the `metrics-endpoint` relation.

You'll get two types of alerts:

- a **warning** alert, when the certificate will expire in less than 30 days;
- a **critical** alert, when the certificate will expire in less than 15 days.

![image|690x353](/assets/alertmanager_BlackboxExporterSSLCertExpiringSoon30Days.png)

If you want to add different alerts, you can use the [cos-configuration-k8s](https://charmhub.io/cos-configuration-k8s) charm to send extra alert rules to Prometheus from a Git repository.

To configure Alertmanager to send you notifications, check [our documentation](https://charmhub.io/alertmanager-k8s).

#### Look at the Grafana dashboard

Navigate to Grafana (on port 3000) to take a look at the dashboard. Login with the default `admin` account: you can get its password by running the `get-admin-password` action:

```bash
juju run grafana/leader get-admin-password
```

Use the sidebar to navigate to the dashboards, and open the "Blackbox Exporter" one in the "General" folder. The dashboard has lots of information, but the part related to certificate expiration should look like this:

![image|690x320](/assets/grafana_ssl_probes.png)

You can sort the table by Certificate Validity by simply clicking on the header, so you can immediately see which certificates will expire first.

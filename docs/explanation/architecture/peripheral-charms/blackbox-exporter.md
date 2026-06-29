# Blackbox Exporter

The Blackbox Exporter is a tool that allows for blackbox probing of endpoints over a multitude of protocols, including HTTP, HTTPS, DNS, TCP, ICMP, and gRPC.

This document will focus on how to use the charm and how to integrate with other charms from the COS Lite bundle. If in doubt, please refer to the [Blackbox Exporter repository](https://github.com/prometheus/blackbox_exporter).

### How does Blackbox Exporter work?

To manually execute a probe with Blackbox Exporter, you'll need an HTTP GET request at the `/probe` path. You can specify three parameters in this query:

- `target`, the endpoint to probe;
- `module`, the type of probe to execute;
- `debug` (optional), to get debug information in the response.

Putting things together, to manually probe `google.com`:

```bash
# Either curl or open it in your browser
curl http://<blackbox-exporter>:9115/probe?target=google.com&module=http_2xx
```

The currently supported modules are: HTTP, HTTPS (via the `http` prober), DNS, TCP socket, ICMP and gRPC, as per the [upstream documentation](https://github.com/prometheus/blackbox_exporter#configuration). You can define custom modules by following the official [examples](https://github.com/prometheus/blackbox_exporter/blob/master/example.yml).

## How to automate the probes

The Blackbox Exporter charm on its own allows for manual probes execution. To run them programmatically, you'll need to integrate it with the [prometheus-k8s charm](https://charmhub.io/prometheus-k8s), which will periodically scrape the `/probe` endpoints you configure, and store the related data.

### Deployment

Deploying the charm works just like any other:

```shell
juju deploy blackbox-exporter-k8s blackbox
# To run probes programmatically, you need Prometheus
juju deploy prometheus-k8s prometheus
juju relate blackbox prometheus
```

### Configuration

There are two configurations you can provide through `juju config` options:

- **the Blackbox exporter configuration file** (optional): this is where you specify and customize which modules are available for the exporter to use (read the [official docs](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md));
- **the probes configuration**: this is the _Prometheus_ scrape jobs configuration, which you should write following [the official docs](https://github.com/prometheus/blackbox_exporter) (and their [examples](https://github.com/prometheus/blackbox_exporter/blob/master/example.yml)).

Please note that, for the probes configuration, the `relabel_configs` section will be overridden by the charm with the correct labels (`__address__`, `__param_target`, `instance` and `probe_target`) and with the appropriate Blackbox Exporter url.

For example, if you want to probe `prometheus.io`, your probes configuration might look like this:

```yaml
--- # probes.yml
scrape_configs:
  - job_name: "prometheus.io_probes"
    metrics_path: /probe
    params:
      module: [http_2xx] # Look for a HTTP 200 response.
    static_configs:
      - targets:
          - http://prometheus.io # Target to probe with http.
          - https://prometheus.io # Target to probe with https.
```

After writing those files, simply pass them to the charm through `juju config`:

```shell
# Blackbox Exporter configuration
juju config blackbox config_file='@/path/to/config.yml'
# Probes configuration
juju config blackbox probes_file='@/path/to/probes.yml'
```

### Self-monitoring

The Blackbox Exporter charm can be integrated with COS Lite to forward logs to [Loki](https://charmhub.io/loki-k8s-operator), provide a dashboard for all the probes to [Grafana](https://charmhub.io/grafana-k8s-operator), and be listed alongside the other COS Lite components in [Catalogue](https://charmhub.io/catalogue-k8s).

![Dashboard|690x405](/assets/grafana_blackbox_exporter_dashboard.png)

(blackbox-exporter)=

# Blackbox Exporter

The Blackbox Exporter charm provides blackbox probing of endpoints over
HTTP, HTTPS, DNS, TCP, ICMP, and gRPC. It extends the COS telemetry pipeline
by producing metrics about the reachability, latency, and certificate
validity of external services — services that don't expose their own
telemetry endpoints.

## How probing works

Blackbox Exporter exposes a `/probe` endpoint. A probe is triggered by an
HTTP GET request with three query parameters:

| Parameter | Purpose                                                |
| --------- | ------------------------------------------------------ |
| `target`  | The endpoint to probe                                  |
| `module`  | The probe type to use (e.g. `http_2xx`, `tcp_connect`) |
| `debug`   | Optional — returns debug information in the response   |

For example, probing `google.com` with the HTTP module:

```bash
curl http://<blackbox-exporter>:9115/probe?target=google.com&module=http_2xx
```

The supported modules follow the
[upstream specification](https://github.com/prometheus/blackbox_exporter#configuration):
HTTP, HTTPS (via the `http` prober), DNS, TCP socket, ICMP, and gRPC.
Custom modules can be defined by following the
[official examples](https://github.com/prometheus/blackbox_exporter/blob/master/example.yml).

On its own, the charm only supports ad-hoc probes. To run probes on a
schedule and store the results, it must be integrated with Prometheus.

## Integration with Prometheus

When related to [`prometheus-k8s`](https://charmhub.io/prometheus-k8s),
the Blackbox Exporter charm forwards its scrape configuration so that
Prometheus periodically hits the `/probe` endpoint for each configured
target. Prometheus stores the resulting metrics as time series data.

```shell
juju deploy blackbox-exporter-k8s blackbox
juju deploy prometheus-k8s prometheus
juju relate blackbox prometheus
```

## Configuration

The charm accepts two configuration files, both supplied via `juju config`:

**Blackbox Exporter configuration** (`config_file`): defines the modules
available to the exporter — which probe types exist and how they behave.
Follows the [upstream configuration format](https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md).

**Probes configuration** (`probes_file`): a Prometheus scrape configuration
that specifies which targets to probe, using which module, and under which
job name. The charm automatically sets the correct `relabel_configs` —
`__address__`, `__param_target`, `instance`, and `probe_target` — so you
don't need to specify them.

Example probes file:

```yaml
--- # probes.yml
scrape_configs:
  - job_name: "prometheus.io_probes"
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - http://prometheus.io
          - https://prometheus.io
```

Apply the configuration:

```shell
juju config blackbox config_file='@/path/to/config.yml'
juju config blackbox probes_file='@/path/to/probes.yml'
```

## Self-monitoring

When integrated with COS, the charm forwards its own
logs to [Loki](https://charmhub.io/loki-k8s-operator), ships a built-in
dashboard covering all configured probes to
[Grafana](https://charmhub.io/grafana-k8s-operator), and registers itself
with [Catalogue](https://charmhub.io/catalogue-k8s) for discoverability.

![Dashboard|690x405](/assets/grafana_blackbox_exporter_dashboard.png)

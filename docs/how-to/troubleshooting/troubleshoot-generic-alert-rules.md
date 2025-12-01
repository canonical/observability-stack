# Troubleshoot generic alert rules
This guide contains steps towards troubleshooting firing generic alert rules. For detailed explanations on the design and goals of these rules, please refer to the explanation page. As mentioned in the explanation page, across the two 

## How to troubleshoot the `HostDown` alert
The `HostDown` alert is a sign that Prometheus is unable to scrape the metrics endpoint of the charm for whom this alert is firing. The methods below can help pinpoint the issue.

### Ensure the workload is running
It is possible that charm being scraped by Prometheus is not running. Use `juju ssh` to shell into the container containing the workload and ensure that the workload is running using `pebble services`. The Pebble service should be active. 

### Ensure Prometheus is scraping the correct endpoint
It is possible that Prometheus is not scraping the correct address, endpoint, or port. When a charm is related to Prometheus for scraping of metrics, the Prometheus config file appends the related charm's metrics endpoint address and port into its list of targets. For K8s charms, this address can be the pod's FQDN or the ingress address (if using Traefik for example). If the charm being scraped does not write the address correctly, then Prometheus will be unable to reach it.
Another possibility is that the charm does not specify the correct port or endpoint for its metrics. When a charm instantiates the `MetricsEndpointProvider` object, it needs to set the correct port and metrics endpoint. For example, Alertmanager exposes its metrics at the `/metrics` endpoint on port 9093. Charm authors should ensure these values are correctly set, otherwise Prometheus may not have the correct information when attempting to scrape. Use the `ss` command to determine which ports are exposed by your workload.

### Ensure the correct firewall and SSL/TLS configurations are applied
From inside the Prometheus container, navigate to its configuration file located at `/etc/promtheus/prometheus.yml`. Find the target of your workload. Attempt to `curl` it from inside that container. Ensure the `curl` is successful. A failed request can be because of firewall issue. Ensure your firewall rules allow Prometheus to reach the instance.

Furthermore, if your workload uses TLS communication, Prometheus needs to trust that CA that signed that workload to be able to reach it. For example, if your charm is signed through an integration to Lego, Prometheus needs to have the CA cert in its root store (through a `receive-ca-cert` relation) so it can communicate in HTTPS with your charm.

## How to troubleshoot the `AggregatorHostHealth` alerts
The `HostMetricsMissing` and `AggregatorMetricsMissing` alerts under are similar, with only differences in their severity and the units they are responsible for. As such, the methods to troubleshoot them are similar.
### Confirm the aggregator is running
Use `juju ssh` to check if the workload is running:
- run `snap list` for machine charms. Ensure the snap is `active`.
- run `pebble services` for k8s charms. Ensure the workload is `active`.

### Confirm the backend is reachable
It is possible that the aggregator is running, but failing to remote write metrics into the metrics backend. This can occur if there are network or firewall issues, leaving the aggregator unable to successfully hit the metrics backend's remote write endpoint.
The causes in these cases can often be revealed by looking at the workload logs and looking for logs that suggest issues in reaching a host. The logs will often mention timeouts, DNS name resolution failures, TLS certificate issues, or more broadly "export failures".
1. for machine aggregators, run `sudo snap logs <snap-name>`.
2. for K8s aggregators, use `juju ssh` and `pebble logs` to view the workload logs. For example, for `opentelemetry-collector-k8s` unit 0, you will need to look at the Pebble logs in the `otelcol` container: `juju ssh -c otelcol opentelemetry-collector/0`.

In some cases, the backend may be unreachable due to SSL/TLS related issues. This often happens when your aggregator is located outside the Juju model where your COS instance lives and your are using TLS communication when the aggregator tries to reach the backend (AKA external or full TLS). If you are using ingress, it is required for the aggregator to trust the CA that signed the backend or ingress provider (e.g. Traefik).  

### Inspect existing `up` time series
Perhaps the metrics *do* reach Prometheus, but the `expr` labels we have rendered in the alert do not match the actual metric labels. You can confirm by going to the Prometheus (or Grafana) UI and querying for `up`. Compare the set of labels you get for the returned `up` time series.

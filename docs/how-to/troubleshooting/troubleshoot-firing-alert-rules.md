# Troubleshoot firing alert rules
This guide describes how to troubleshoot firing generic alert rules. For detailed explanations on the design and goals of these rules, refer to the [explanation page](/explanation/generic-rules).

## How to troubleshoot the `HostDown` alert
The `HostDown` alert is a sign that Prometheus is unable to scrape the metrics endpoint of the charm for whom this alert is firing. The methods below can help pinpoint the issue.

### Ensure the workload is running
It is possible that the charm being scraped by Prometheus is not running. Shell into the workload container and check the service status:
```shell
juju ssh <the rest of the commands including `pebble services`>
```

### Ensure Prometheus is scraping the correct endpoint
It is possible that Prometheus is not scraping the correct address, endpoint, or port. When a charm is related to Prometheus for scraping of metrics, the Prometheus config file appends the related charm's metrics endpoint address and port into its list of targets. For K8s charms, this address can be the pod's FQDN or the ingress address (if using Traefik for example). If the charm being scraped does not write the address correctly, then Prometheus will be unable to reach it.

Another possibility is that the charm does not specify the correct port or endpoint for its metrics. When a charm instantiates the `MetricsEndpointProvider` object, it needs to set the correct port and metrics endpoint. For example, Alertmanager exposes its metrics at the `/metrics` endpoint on port 9093. Charm authors should ensure these values are correctly set, otherwise Prometheus may not have the correct information when attempting to scrape. Use the `ss` command to determine which ports are exposed by your workload.

### Ensure the correct firewall and SSL/TLS configurations are applied
From inside the Prometheus container:
1. View the Prometheus configuration file located at `/etc/prometheus/prometheus.yml`
```shell
cat /etc/prometheus/prometheus.yml
```
2. Find the address of your target
3. Attempt to `curl` it from inside that container.
```shell
curl <address of your workload>
```
4. Ensure the `curl` request is successful

A failed request can be due to a firewall issue. Ensure your firewall rules allow Prometheus to reach the instance.

If your workload uses TLS communication, Prometheus needs to trust that CA that signed that workload to be able to reach it. For example, if your charm is signed through an integration to Lego, Prometheus needs to have the CA cert in its root store (through a `receive-ca-cert` relation) so it can communicate in HTTPS with your charm.

## How to troubleshoot the `AggregatorHostHealth` alerts
The `HostMetricsMissing` and `AggregatorMetricsMissing` alerts under the `AggregatorHostHealth` group are similar, with only differences in their severity and the units they are responsible for. As such, the methods to troubleshoot them are identical.
### Confirm the aggregator is running
For machine charms, ensure the snap is running by checking its status in the machine hosting it. In this example, we'll assume that our aggregator is `grafana-agent` on a machine with ID 0.
1. Shell into the machine.
```shell
juju ssh 0
```
2. Check the status of the `grafana-agent` snap
```shell 
sudo snap services grafana-agent
```
Ensure that the status of the snap is indicated as `active`.

For K8s charms, ensure the relevant pebble service is running by checking its status in the workload container. In this example, we'll assume we have the `opentelemetry-collector` k8s charm deployed with the name `otel` and we want to check the status of the pebble service in the workload container in unit 0. The name of the workload container is `otelcol`.
```{note}
You need to know the name of the workload container in order to shell into it. You can find this information by consulting the `containers` section of a charm's `charmcraft.yaml` file. Alternatively, you can use `kubectl describe pod` to view the containers inside the pod.    
```
1. Shell into the workload container
```shell 
juju ssh --container otelcol otel/0
```
2. Check the status of the `otelcol` pebble service
```shell 
pebble services otelcol
```

### Confirm the backend is reachable
It is possible that the aggregator is running, but failing to remote write metrics into the metrics backend. This can occur if there are network or firewall issues, leaving the aggregator unable to successfully hit the metrics backend's remote write endpoint.

The causes in these cases can often be revealed by looking at the workload logs and looking for logs that suggest issues in reaching a host. The logs will often mention timeouts, DNS name resolution failures, TLS certificate issues, or more broadly "export failures".
1. For machine aggregators, run `sudo snap logs <snap-name>`.
2. For K8s aggregators, use `juju ssh` and `pebble logs` to view the workload logs. For example, for `opentelemetry-collector-k8s` unit 0, you will need to look at the Pebble logs in the `otelcol` container: `juju ssh --container otelcol opentelemetry-collector/0 pebble logs`.

In some cases, the backend may be unreachable due to SSL/TLS related issues. This often happens when your aggregator is located outside the Juju model where your COS instance lives and you are using TLS communication when the aggregator tries to reach the backend (external or full TLS). If you are using ingress, it is required for the aggregator to trust the CA that signed the backend or ingress provider (e.g. Traefik).

### Inspect existing `up` time series
Perhaps the metrics *do* reach Prometheus, but the `expr` labels we have rendered in the alert do not match the actual metric labels. You can confirm by going to the Prometheus (or Grafana) UI and querying for `up`. Compare the set of labels you get for the returned `up` time series.

---
myst:
 html_meta:
   description: "Migrate from Grafana Agent to OpenTelemetry Collector due to Grafana Agent reaching end-of-life."
---

# How to migrate from Grafana Agent to OpenTelemetry Collector

> Grafana Agent has reached End-of-Life (EOL) on November 1, 2025.

Grafana Agent is no longer receiving support, security, or bug fixes from the vendor. Since it is part of COS, the charmed operators for Grafana Agent will continue to  receive bug fixes until July 2026. You should plan to migrate from charmed Grafana Agent to charmed Opentelemetry Collector before that date.

These are the steps to follow:

## Prerequisites
- Ensure you are using Juju 3.6+. [Upgrade Juju](https://documentation.ubuntu.com/juju/latest/reference/upgrading-things/index.html) first if necessary.

<br>

### Deploy the collector next to the agent charm
#### Machine model

Replace the value for `--base` to be consistent with your existing model. 

```{note}
If port 8888 (or others) is already taken by another application (e.g. haproxy), use a config option to override the default with e.g. 8889.
```

```
juju deploy opentelemetry-collector otelcol \
  --channel 2/stable \
  --base ubuntu@22.04 \
  --config ports="metrics=8889"  # optional
```

#### Kubernetes Model
```
juju deploy opentelemetry-collector-k8s otelcol --channel 2/stable
```
<br>

### Inspect grafana-agent integrations, and replicate them for the otelcol collector

```{note}
- Some relation endpoints have slightly different names, for clarity:
  - `logging-consumer` is now `send-loki-logs`
  - `grafana-cloud-config` is now `cloud-config`
```

The best way is to copy the workload charm relation endpoint that was connected to `grafana-agent`
```
juju status --relations grafana-agent | grep "grafana-agent:" | grep -v ":peers"
```
This is a sample relation output:
```
grafana-agent:grafana-dashboards-provider             grafana:grafana-dashboard                           grafana_dashboard        regular      
keystone:juju-info                                    grafana-agent:juju-info                             juju-info                subordinate  
prometheus-recieve-remote-write:receive-remote-write  grafana-agent:send-remote-write                     prometheus_remote_write  regular
```
Then integrate each of those charms with otelcol, for example:
```
juju integrate otelcol grafana:grafana-dashboard
juju integrate otelcol keystone:juju-info
juju integrate otelcol prometheus-receive-remote-write:receive-remote-write
```
and so on.

If you get a `quota limit exceeded` error,  for example
```
ERROR cannot add relation "otelcol:cos-agent openstack-exporter:cos-agent": establishing a new relation for openstack-exporter:cos-agent would exceed its maximum relation limit of 1 (quota limit exceeded)                               
```

Then remove the relation from the payload first and then try again.
```
juju remove-relation grafana-agent openstack-exporter:cos-agent
juju integrate otelcol openstack-exporter:cos-agent
```
<br>

### Verify that data is appearing in the backends (Mimir, Prometheus, Loki, etc.)
```{tip}
For metrics, the tags are visible in the Grafana dashboard section. For logs you can run a query from the Explore page and select one of the logs to see which `juju_application` ingested it. 
```
<br>

### Remove grafana-agent from your deployment
```
juju remove-application grafana-agent --destroy-storage
```

## Known Issues



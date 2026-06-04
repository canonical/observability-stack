---
myst:
  html_meta:
    description: "Send metrics from uncharmed workloads to standalone Mimir on Juju by using the OpenTelemetry Collector snap as a scraper and remote_write client."
---

# How to send metrics to Mimir

Use this guide when your workload is **not** managed by Juju and you want to
ship its metrics into standalone Mimir.

The recommended path is to run the OpenTelemetry Collector snap near the
uncharmed workload, scrape its `/metrics` endpoint, and forward those metrics
to Mimir over Prometheus `remote_write`.

For the standalone Mimir deployment itself, see
[Get started with standalone Mimir on Juju](/tutorial/mimir-on-juju).

## Prerequisites

- A working standalone Mimir deployment with ingress enabled.
- An uncharmed workload that exposes Prometheus-format metrics.
- A machine where you can install the OpenTelemetry Collector snap and that can:
  - reach the workload metrics endpoint
  - reach the Mimir ingress URL

## 1. Get the Mimir URL

In the Juju model where Mimir is deployed, run:

```bash
juju run traefik/0 show-proxied-endpoints --format=yaml \
    | yq '."traefik/0".results."proxied-endpoints"' \
    | jq
```

Look for the `mimir` entry:

```json
{
  "mimir": {
    "url": "http://10.43.8.34:80/mimir"
  }
}
```

You will use:

- `<mimir-url>/api/v1/push` for ingestion
- `<mimir-url>/prometheus/api/v1/query` for verification

## 2. Install the OpenTelemetry Collector snap

On the machine that can reach the uncharmed workload:

```bash
sudo snap install opentelemetry-collector
```

We recommend placing the collector as close as possible to the workload to
reduce network hops and avoid losing telemetry during transient failures.

## 3. Create the collector configuration

Write a collector config file under `/etc/otelcol/config.d/`.

This example scrapes a workload that exposes metrics on `http://my-workload:9000/metrics`
and forwards them to Mimir:

```yaml
receivers:
  prometheus:
    config:
      scrape_configs:
        - job_name: "my-workload"
          scrape_interval: 15s
          static_configs:
            - targets: ["my-workload:9000"]

exporters:
  prometheusremotewrite:
    endpoint: "http://10.43.8.34:80/mimir/api/v1/push"
    headers:
      X-Scope-OrgID: anonymous

service:
  pipelines:
    metrics:
      receivers: [prometheus]
      exporters: [prometheusremotewrite]
```

Save it as:

```bash
sudo mkdir -p /etc/otelcol/config.d
sudo editor /etc/otelcol/config.d/otelcol_mimir.yaml
```

Replace:

- `my-workload:9000` with the address of your workload's metrics endpoint
- `http://10.43.8.34:80/mimir/api/v1/push` with your actual Mimir ingress URL

## 4. Restart the collector

```bash
sudo snap restart opentelemetry-collector
```

If you want to confirm the collector started cleanly:

```bash
sudo snap logs opentelemetry-collector
```

## 5. Verify that metrics reached Mimir

Query Mimir's Prometheus-compatible API:

```bash
MIMIR_URL=http://10.43.8.34:80/mimir

curl -sG "$MIMIR_URL/prometheus/api/v1/query" \
    --data-urlencode 'query=up{job="my-workload"}' \
    | jq
```

If the pipeline is working, the query returns a successful result for the
`my-workload` job.

## HTTPS and private CAs

If either the workload metrics endpoint or the Mimir ingress URL uses TLS signed
by a private CA, install that CA into the machine trust store used by the snap.

See the CA-handling guidance in
[How to integrate COS Lite with uncharmed applications](integrating-cos-lite-with-uncharmed-applications).

## Adapting the scrape config

The example above uses a single static target, but the same pattern works for:

- multiple targets in one job
- multiple scrape jobs
- custom `metrics_path` values
- authenticated or HTTPS endpoints

The important part is that the metrics pipeline ends with the
`prometheusremotewrite` exporter pointing at:

```text
<mimir-url>/api/v1/push
```

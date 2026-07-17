---
myst:
  html_meta:
    description: "Send metrics from applications outside Juju into a Mimir on Juju deployment by using the OpenTelemetry Collector snap as a scraper and remote_write client."
---

# How to send metrics to Mimir on Juju

Use this guide to send metrics from an application that is **not** managed by
Juju into a Mimir on Juju deployment.

## What this guide sets up

Mimir on Juju accepts metrics over Prometheus `remote_write` through its
`receive-remote-write` relation. When the sender is another charm, that
relation does everything for you. When the sender is an uncharmed workload
(for example, a plain systemd service on a VM), there is no relation to
attach to, so you need something outside Juju that can:

1. scrape or receive metrics from the workload, and
2. push them into Mimir's `remote_write` endpoint through the Mimir
   ingress URL.

We use the [OpenTelemetry Collector
snap](https://snapcraft.io/opentelemetry-collector) for this. The **snap**
(not the charm) is a standalone binary you install directly on the machine
that runs, or can reach, the uncharmed workload. It is configured through a
YAML file placed in `/etc/otelcol/config.d/`. We recommend running it as
close as possible to the workload to minimize network hops and reduce the
chance of losing telemetry during transient failures.

The end result is: `uncharmed workload` -> `otelcol snap` -(remote_write over
Traefik ingress)-> `Mimir on Juju`.

For a general primer on this pattern with the full COS Lite stack, see
[How to integrate COS Lite with uncharmed applications](integrating-cos-lite-with-uncharmed-applications).
For the Mimir deployment itself, see
[How to deploy Mimir on Juju](/how-to/deploy-and-manage/deploy-mimir-on-juju).

## Prerequisites

- A working Mimir on Juju deployment with ingress enabled (see
  [How to deploy Mimir on Juju](/how-to/deploy-and-manage/deploy-mimir-on-juju)).
- An uncharmed workload that exposes Prometheus-format metrics.
- A machine where you can install the OpenTelemetry Collector snap and that
  can:
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

## 3. Create the collector configuration

Write a collector config file under `/etc/otelcol/config.d/`. The snap loads
every YAML file it finds in that directory and merges them, so you can drop
in additional files later for more workloads without editing the existing
one.

The pipeline below scrapes a workload that exposes metrics on
`http://my-workload:9000/metrics` and forwards them to Mimir over
`remote_write`. The `prometheus` receiver acts as the scraper, and the
`prometheusremotewrite` exporter pushes into Mimir's ingestion URL. The
`X-Scope-OrgID` header is required by Mimir's multi-tenant API; use
`anonymous` for a single-tenant deployment.

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

If either the workload metrics endpoint or the Mimir ingress URL uses TLS
signed by a private CA, install that CA into the machine trust store used by
the snap.

See the CA-handling guidance in
[How to integrate COS Lite with uncharmed applications](integrating-cos-lite-with-uncharmed-applications).

## Adapting the scrape config

The example above uses a single static target, but the same pattern works
for:

- multiple targets in one job
- multiple scrape jobs
- custom `metrics_path` values
- authenticated or HTTPS endpoints

The important part is that the metrics pipeline ends with the
`prometheusremotewrite` exporter pointing at:

```text
<mimir-url>/api/v1/push
```

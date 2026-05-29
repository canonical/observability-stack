---
myst:
  html_meta:
    description: "Deploy standalone Grafana Mimir on Juju with a small worker topology, S3-backed storage, and a minimal remote_write validation path."
---

# Get started with standalone Mimir on Juju

This tutorial is for readers who already know upstream Grafana Mimir and want
the Juju-native path to a working deployment.

You will deploy a small standalone Mimir topology on Kubernetes, back it with
S3-compatible object storage, expose it through Traefik, and confirm that it
can ingest metrics over `prometheus_remote_write`.

```{important}
This guide uses the Juju CLI because it is the clearest way to learn how the
deployment fits together. For repeatable environments and production-oriented
rollouts, prefer the
[Mimir Terraform module](https://github.com/canonical/mimir-operators/tree/main/terraform).
```

## Prerequisites

- Juju 3.6 or later, with a Kubernetes cloud added and a controller already
  bootstrapped.
- A Kubernetes cluster ready to host the Mimir model.
- An S3-compatible object store that already exists, including:
  - endpoint
  - bucket name
  - access key
  - secret key
- A routable ingress address for Traefik if you want to query Mimir from
  outside the cluster.

If you still need to prepare storage, see
[How to configure object storage for Mimir](../how-to/integrate/configure-object-storage-for-mimir).

## 1. Create a model

```bash
juju add-model mimir
juju switch mimir
```

## 2. Deploy Mimir and its supporting charms

Deploy the coordinator, one worker application, Traefik, and an S3 integrator.

This tutorial uses a compact worker layout for ease of demonstration. The
single `mimir-worker` application runs with `role-all=true`, which keeps the
deployment small while still exercising the coordinator, storage, ingress, and
ingestion flows.

For higher availability and more production-like scaling, split the worker tier
into dedicated `mimir-write`, `mimir-read`, and `mimir-backend` applications
instead of using this monolithic worker setup. You can then scale each role
independently according to ingestion, query, and storage pressure.

The tutorial worker also uses `role-query-frontend=true` so queries go through
the same frontend path you will use later.

```bash
juju deploy mimir-coordinator-k8s mimir --trust

juju deploy mimir-worker-k8s mimir-worker \
    --trust \
    --config role-all=true \
    --config role-query-frontend=true

juju deploy s3-integrator mimir-s3 --channel latest/stable --trust
juju deploy traefik-k8s traefik --trust
```

## 3. Point the S3 integrator at your object storage

Replace the placeholder values with your existing S3-compatible storage
details:

```bash
juju add-secret mimir-s3-credentials \
    access-key=<access-key> \
    secret-key=<secret-key>

juju grant-secret mimir-s3-credentials mimir-s3

juju config mimir-s3 \
    credentials=mimir-s3-credentials \
    endpoint=<s3-endpoint> \
    bucket=<bucket-name>
```

If your object store needs additional settings such as a custom CA chain,
region, or path-style addressing, see
[How to configure object storage for Mimir](../how-to/integrate/configure-object-storage-for-mimir).

## 4. Integrate the deployment

Connect storage first, then join the worker and ingress relations:

```bash
juju integrate mimir:s3 mimir-s3:s3-credentials
juju integrate mimir:mimir-cluster mimir-worker:mimir-cluster
juju integrate traefik:ingress mimir:ingress
```

Watch the model until all applications settle:

```bash
juju status --relations --watch=5s
```

At this point Mimir should expose at least:

- `receive-remote-write` for metrics ingestion
- `ingress` for external access
- `self-metrics-endpoint` for scrape-based validation flows

## 5. Validate metric ingestion with OpenTelemetry Collector

For a minimal smoke test, deploy:

- `avalanche-k8s` as a small metrics generator
- `opentelemetry-collector-k8s` as the sender that scrapes Avalanche and
  forwards the metrics to Mimir over `prometheus_remote_write`

```bash
juju deploy opentelemetry-collector-k8s otelcol --trust
juju deploy avalanche-k8s avalanche --trust

juju integrate avalanche otelcol:metrics-endpoint
juju integrate otelcol:send-remote-write mimir:receive-remote-write
```

Wait for the applications to become active:

```bash
juju status --relations --watch=5s
```

## 6. Query Mimir

Use the Traefik action to get the Mimir URL:

```bash
juju run traefik/0 show-proxied-endpoints --format=yaml \
    | yq '."traefik/0".results."proxied-endpoints"' \
    | jq
```

The output includes a `mimir` entry similar to:

```json
{
  "mimir": {
    "url": "http://10.43.8.34:80/mimir"
  }
}
```

Save that URL and query Mimir's Prometheus-compatible API:

```bash
MIMIR_URL=http://10.43.8.34:80/mimir

curl -sG "$MIMIR_URL/prometheus/api/v1/query" \
    --data-urlencode 'query=count({__name__=~"avalanche_metric_.+"})' \
    | jq
```

You should see a successful query response with a value greater than `0`.

## What you deployed

This tutorial uses a small Juju-native Mimir deployment:

- `mimir-coordinator-k8s` provides the public API surface
- `mimir-worker-k8s` runs the actual Mimir workload roles
- `s3-integrator` supplies object-store connection details to Mimir
- `traefik-k8s` gives you a stable URL for querying and ingestion

That is enough to run Mimir standalone. It also fits naturally into the wider
COS architecture if you later add Grafana, Loki, Alertmanager, or more
specialized telemetry pipelines.

## Next steps

- For storage details and production-oriented caveats, see
  [How to configure object storage for Mimir](../how-to/integrate/configure-object-storage-for-mimir).
- For more ways to send metrics into Mimir, including cross-model relations and
  direct `remote_write` clients, see
  [How to send metrics to Mimir](../how-to/integrate/send-metrics-to-mimir).

---
myst:
  html_meta:
    description: "Deploy Grafana Mimir on Juju with a small worker topology, S3-backed storage, and a minimal remote_write validation path, without the full COS bundle."
---

# How to deploy Mimir on Juju

This guide deploys Grafana Mimir on Kubernetes using
[Juju](https://documentation.ubuntu.com/juju/3.6/), Canonical's operator
lifecycle manager, without pulling in the full Canonical Observability Stack
(COS) bundle. It targets readers who already know upstream Mimir and want the
Juju-native path to a working, Mimir-focused deployment.

If you are new to Juju, skim the [Juju documentation](https://documentation.ubuntu.com/juju/3.6/)
first — especially [Juju: get started](https://documentation.ubuntu.com/juju/3.6/tutorial/)
and the [Juju reference](https://documentation.ubuntu.com/juju/3.6/reference/)
for the meaning of terms like *model*, *application*, *unit*, and *relation*.
The runtime you get from this guide is upstream Mimir; the *charms* just handle
configuration, storage wiring, ingress, and inter-component relations.

For a full COS deployment (Grafana, Alertmanager, Loki, etc.) instead of a
Mimir-focused one, see
[Getting started with COS on Canonical K8s](/tutorial/cos-canonical-k8s-sandbox).

```{important}
This guide uses the Juju CLI because it is the clearest way to see how the
deployment fits together. For repeatable environments and production-oriented
rollouts, prefer the
[Mimir Terraform module](https://github.com/canonical/mimir-operators/tree/main/terraform).
```

## What this guide deploys

Mimir infrastructure (required for Mimir to run):

- `mimir-coordinator-k8s` — the public API and coordinator for the Mimir
  cluster.
- `mimir-worker-k8s` — a single worker application configured to run all
  Mimir roles (`role-all=true`). In production, split this into dedicated
  `mimir-write`, `mimir-read`, and `mimir-backend` applications and scale each
  role independently.
- `s3-integrator` (deployed as `mimir-s3`) — supplies Mimir with an S3
  endpoint and credentials. Mimir requires S3-compatible object storage; the
  charm does not provide the object store itself, only the connection
  details.

Supporting infrastructure (not part of Mimir itself, but used here for a
usable end-to-end flow):

- `traefik-k8s` — gives Mimir a stable URL for ingestion and querying from
  outside the cluster.
- `opentelemetry-collector-k8s` (`otelcol`) — used only in the validation
  step to scrape a test workload and push metrics to Mimir over
  `prometheus_remote_write`.
- `avalanche-k8s` — a synthetic metrics generator used only in the
  validation step.

The worker also uses `role-query-frontend=true` so queries you run later go
through the same frontend path as a real deployment.

## Prerequisites

- Juju 3.6 or later, with a Kubernetes cloud added and a controller
  bootstrapped. See
  [Juju: install Juju](https://documentation.ubuntu.com/juju/3.6/howto/manage-juju/#install-juju),
  [Juju: add a Kubernetes cloud](https://documentation.ubuntu.com/juju/3.6/howto/manage-clouds/#add-a-kubernetes-cloud),
  and [Juju: bootstrap a controller](https://documentation.ubuntu.com/juju/3.6/howto/manage-controllers/).
- A Kubernetes cluster ready to host the Mimir model. For a local option,
  see [Canonical Kubernetes: get started](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/tutorial/getting-started/).
- An S3-compatible object store that already exists, with an endpoint,
  bucket, access key, and secret key. If you do not have one, see
  [How to deploy Minio and S3 Integrator](../integrate/deploy-s3-integrator-and-minio)
  for a disposable test store. For the connection steps in more detail, see
  [How to connect object storage to Mimir on Juju](../integrate/configure-object-storage-for-mimir).
- A routable ingress address for Traefik if you want to query Mimir from
  outside the cluster. See the [networking best practices](/reference/networking).

## 1. Create a model

A Juju [*model*](https://documentation.ubuntu.com/juju/3.6/reference/model/)
is a workspace on the controller that holds a set of related applications.
Create one dedicated to Mimir:

```bash
juju add-model mimir
juju switch mimir
```

## 2. Deploy Mimir and its supporting charms

Deploy the Mimir coordinator, one worker application, an S3 integrator, and
Traefik:

```bash
juju deploy mimir-coordinator-k8s mimir --trust

juju deploy mimir-worker-k8s mimir-worker \
    --trust \
    --config role-all=true \
    --config role-query-frontend=true

juju deploy s3-integrator mimir-s3 --channel latest/stable --trust
juju deploy traefik-k8s traefik --trust
```

`--trust` grants the charm access to the Kubernetes API on the host cluster,
which the Mimir, S3 integrator, and Traefik charms need to create the
resources they manage.

## 3. Point the S3 integrator at your object storage

The `mimir-s3` application starts in `blocked` status until it has both
credentials and a target bucket. Create a Juju secret with the S3
credentials, grant that secret to `mimir-s3`, then configure the endpoint
and bucket.

Replace the placeholders with your existing S3-compatible storage details:

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
[How to connect object storage to Mimir on Juju](../integrate/configure-object-storage-for-mimir).

## 4. Integrate the deployment

Connect storage first, then join the worker and ingress relations:

```bash
juju integrate mimir:s3 mimir-s3:s3-credentials
juju integrate mimir:mimir-cluster mimir-worker:mimir-cluster
juju integrate traefik:ingress mimir:ingress
```

Watch the model until every application reaches `active/idle`. That is the
Juju status meaning the charm has finished reconciling and is running as
configured; other transient statuses (`waiting`, `maintenance`, `blocked`)
indicate the deployment is still converging or missing something:

```bash
juju status --relations --watch=5s
```

At this point Mimir should expose at least:

- `receive-remote-write` for metrics ingestion
- `ingress` for external access
- `self-metrics-endpoint` for scrape-based validation flows

## 5. Validate metric ingestion with OpenTelemetry Collector

For a minimal smoke test, deploy:

- `avalanche-k8s` — a small synthetic metrics generator.
- `opentelemetry-collector-k8s` — a scraper and forwarder charm that
  collects Avalanche's metrics and pushes them to Mimir over
  `prometheus_remote_write`.

Neither of these is required for Mimir itself. They only exist here to prove
the ingestion path works end-to-end:

```bash
juju deploy opentelemetry-collector-k8s otelcol --trust
juju deploy avalanche-k8s avalanche --trust

juju integrate avalanche otelcol:metrics-endpoint
juju integrate otelcol:send-remote-write mimir:receive-remote-write
```

Wait for the applications to reach `active/idle`:

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

## Next steps

- For storage details and production-oriented caveats, see
  [How to connect object storage to Mimir on Juju](../integrate/configure-object-storage-for-mimir).
- For more ways to send metrics into Mimir, including cross-model relations
  and direct `remote_write` clients, see
  [How to send metrics to Mimir on Juju](../integrate/send-metrics-to-mimir).
- To grow this into a full Canonical Observability Stack with Grafana, Loki,
  Alertmanager, and correlated telemetry, see
  [Getting started with COS on Canonical K8s](/tutorial/cos-canonical-k8s-sandbox).

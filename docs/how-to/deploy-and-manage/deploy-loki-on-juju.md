---
myst:
  html_meta:
    description: "Deploy Grafana Loki on Juju with a small worker topology, S3-backed storage, and a minimal log-ingestion validation path, without the full COS bundle."
---

# How to deploy Loki on Juju

This guide deploys Grafana Loki on Kubernetes using
[Juju](https://documentation.ubuntu.com/juju/3.6/), Canonical's operator
lifecycle manager, without pulling in the full Canonical Observability Stack
(COS) bundle. It targets readers who already know upstream Loki and want the
Juju-native path to a working, Loki-focused deployment.

If you are new to Juju, skim the [Juju documentation](https://documentation.ubuntu.com/juju/3.6/)
first -- especially [Juju: get started](https://documentation.ubuntu.com/juju/3.6/tutorial/)
and the [Juju reference](https://documentation.ubuntu.com/juju/3.6/reference/)
for the meaning of terms like *model*, *application*, *unit*, and *relation*.
The runtime you get from this guide is upstream Loki; the *charms* just handle
configuration, storage wiring, ingress, and inter-component relations.

For a full COS deployment (Grafana, Alertmanager, Mimir, etc.) instead of a
Loki-focused one, see
[Getting started with COS on Canonical K8s](/tutorial/cos-canonical-k8s-sandbox).

```{include} /reuse/loki-on-juju-nav.md
```

```{important}
This guide uses the Juju CLI because it is the clearest way to see how the
deployment fits together. For repeatable environments and production-oriented
rollouts, prefer the
[Loki Terraform module](https://github.com/canonical/loki-operators/tree/main/terraform).
```

## What this guide deploys

Loki infrastructure (required for Loki to run):

- `loki-coordinator-k8s`: the public API and coordinator for the Loki
  cluster.
- `loki-worker-k8s`: a single worker application configured to run all
  Loki roles (`role-all=true`). In production, split this into dedicated
  `loki-write`, `loki-read`, and `loki-backend` applications and scale each
  role independently.
- `s3-integrator` (deployed as `loki-s3`): supplies Loki with an S3
  endpoint and credentials. Loki requires S3-compatible object storage; the
  charm does not provide the object store itself, only the connection
  details.

Supporting infrastructure (not part of Loki itself, but used here for a
usable end-to-end flow):

- `traefik-k8s`: gives Loki a stable URL for ingestion and querying from
  outside the cluster.
- `flog-k8s`: a fake-log generator used only in the validation step to
  produce a stream of synthetic log lines.
- `opentelemetry-collector-k8s` (`otelcol`): used only in the validation
  step to receive flog's output and route it to the Loki ingress via the
  `logging` relation. Note, however, that in most production deployments,
  Otelcol is the component responsible for collecting logs from workloads and
  forwarding them to Loki.


## Prerequisites

- Juju 3.6 or later, with a Kubernetes cloud added and a controller
  bootstrapped. See
  [Juju: install Juju](https://documentation.ubuntu.com/juju/3.6/howto/manage-juju/#install-juju),
  [Juju: add a Kubernetes cloud](https://documentation.ubuntu.com/juju/3.6/howto/manage-clouds/#add-a-kubernetes-cloud),
  and [Juju: bootstrap a controller](https://documentation.ubuntu.com/juju/3.6/howto/manage-controllers/).
- A Kubernetes cluster ready to host the Loki model. For a local option,
  see [Canonical Kubernetes: get started](https://documentation.ubuntu.com/canonical-kubernetes/latest/snap/tutorial/getting-started/).
- An S3-compatible object store that already exists, with an endpoint,
  bucket, access key, and secret key. If you do not have one, see
  [How to deploy Minio and S3 Integrator](../integrate/deploy-s3-integrator-and-minio)
  for a disposable test store. For the connection steps in more detail, see
  [How to connect object storage to Loki on Juju](../integrate/configure-object-storage-for-loki).
- A routable ingress address for Traefik if you want to query Loki from
  outside the cluster. See the [networking best practices](/reference/networking).

## 1. Create a model

A Juju [*model*](https://documentation.ubuntu.com/juju/3.6/reference/model/)
is a workspace on the controller that holds a set of related applications.
Create one dedicated to Loki:

```bash
juju add-model loki
juju switch loki
```

## 2. Deploy Loki and its supporting charms

Deploy the Loki coordinator, one worker application, an S3 integrator, and
Traefik:

```bash
juju deploy loki-coordinator-k8s loki --trust

juju deploy loki-worker-k8s loki-worker \
    --trust \
    --config role-all=true

juju deploy s3-integrator loki-s3 --channel latest/stable --trust
juju deploy traefik-k8s traefik --trust
```

`--trust` grants the charm access to the Kubernetes API on the host cluster,
which the Loki, S3 integrator, and Traefik charms need to create the
resources they manage.

## 3. Point the S3 integrator at your object storage

The `loki-s3` application starts in `blocked` status until it has both
credentials and a target bucket. Create a Juju secret with the S3
credentials, grant that secret to `loki-s3`, then configure the endpoint
and bucket.

Replace the placeholders with your existing S3-compatible storage details:

```bash
juju add-secret loki-s3-credentials \
    access-key=<access-key> \
    secret-key=<secret-key>

juju grant-secret loki-s3-credentials loki-s3

juju config loki-s3 \
    credentials=loki-s3-credentials \
    endpoint=<s3-endpoint> \
    bucket=<bucket-name>
```

If your object store needs additional settings such as a custom CA chain,
region, or path-style addressing, see
[How to connect object storage to Loki on Juju](../integrate/configure-object-storage-for-loki).

## 4. Integrate the deployment

Connect storage first, then join the worker and ingress relations:

```bash
juju integrate loki:s3 loki-s3:s3-credentials
juju integrate loki:loki-cluster loki-worker:loki-cluster
juju integrate traefik:ingress loki:ingress
```

Watch the model until every application reaches `active/idle`. That is the
Juju status meaning the charm has finished reconciling and is running as
configured; other transient statuses (`waiting`, `maintenance`, `blocked`)
indicate the deployment is still converging or missing something:

```bash
juju status --relations --watch=5s
```

At this point Loki should expose at least:

- `logging` for log ingestion
- `ingress` for external access
- `self-metrics-endpoint` for scrape-based validation flows

## 5. Validate log ingestion with OpenTelemetry Collector

For a minimal smoke test, deploy:

- `flog-k8s`, which generates a stream of fake Apache-format log lines.
- `opentelemetry-collector-k8s`, which collects flog's output and forwards
  it to Loki over the `logging` relation.

Neither of these is required for Loki itself. They only exist here to prove
the ingestion path works end-to-end:

```bash
juju deploy opentelemetry-collector-k8s otelcol --trust
juju deploy flog-k8s flog --channel latest/edge --trust

juju integrate flog:log-proxy otelcol:receive-loki-logs
juju integrate otelcol:send-loki-logs loki:logging
```

Wait for the applications to reach `active/idle`:

```bash
juju status --relations --watch=5s
```

## 6. Query Loki

Use the Traefik action to get the Loki URL:

```bash
juju run traefik/0 show-proxied-endpoints --format=yaml \
    | yq '."traefik/0".results."proxied-endpoints"' \
    | jq
```

The output includes a `loki` entry similar to:

```json
{
  "loki": {
    "url": "http://10.43.8.34:80/loki"
  }
}
```

Save that URL and query Loki's LogQL API:

```bash
LOKI_URL=http://10.43.8.34:80/loki

curl -sG "$LOKI_URL/loki/api/v1/query_range" \
    --data-urlencode 'query={juju_charm=~".*flog.*"}' \
    | jq
```

You should see a successful query response with log entries from the
`flog-k8s` application.

## Next steps

- For storage details and production-oriented caveats, see
  [How to connect object storage to Loki on Juju](../integrate/configure-object-storage-for-loki).
- For more ways to send logs into Loki, including cross-model relations and
  direct Promtail or OpenTelemetry Collector clients, see
  [How to send logs to Loki on Juju](../integrate/send-logs-to-loki).
- To grow this into a full Canonical Observability Stack with Grafana, Mimir,
  Alertmanager, and correlated telemetry, see
  [Getting started with COS on Canonical K8s](/tutorial/cos-canonical-k8s-sandbox).

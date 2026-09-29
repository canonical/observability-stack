---
myst:
  html_meta:
    description: "Send logs from applications outside Juju into a Loki on Juju deployment by using the OpenTelemetry Collector snap as a log forwarder."
---

# How to send logs to Loki on Juju

Use this guide to send logs from an application that is **not** managed by
Juju into a Loki on Juju deployment.

## What this guide sets up

Loki on Juju accepts logs through its `logging` relation. When the sender is
another charm, that relation does everything for you. When the sender is an
uncharmed workload (for example, a plain systemd service writing to a log
file on a VM), there is no relation to attach to, so you need something
outside Juju that can:

1. tail the workload's log file (or otherwise collect its log output), and
2. push them into Loki's ingestion endpoint through the Loki ingress URL.

We use the [OpenTelemetry Collector
snap](https://snapcraft.io/opentelemetry-collector) for this. The **snap**
(not the charm) is a standalone binary you install directly on the machine
that runs, or can reach, the uncharmed workload. It is configured through a
YAML file placed in `/etc/otelcol/config.d/`. We recommend running it as
close as possible to the workload to minimize network hops and reduce the
chance of losing telemetry during transient failures.

The end result is: `uncharmed workload` -> `otelcol snap` -(Loki push API
over Traefik ingress)-> `Loki on Juju`.

For a general primer on this pattern with the full COS Lite stack, see
[How to integrate COS Lite with uncharmed applications](integrating-cos-lite-with-uncharmed-applications).
For the Loki deployment itself, see
[How to deploy Loki on Juju](/how-to/deploy-and-manage/deploy-loki-on-juju).

```{include} /reuse/loki-on-juju-nav.md
```

## Prerequisites

- A working Loki on Juju deployment with ingress enabled (see
  [How to deploy Loki on Juju](/how-to/deploy-and-manage/deploy-loki-on-juju)).
- An uncharmed workload that writes logs to a file or emits them over a
  supported protocol.
- A machine where you can install the OpenTelemetry Collector snap and that
  can:
  - reach the workload's log output (e.g. the log file on disk)
  - reach the Loki ingress URL

## 1. Get the Loki URL

In the Juju model where Loki is deployed, run:

```bash
juju run traefik/0 show-proxied-endpoints --format=yaml \
    | yq '."traefik/0".results."proxied-endpoints"' \
    | jq
```

Look for the `loki` entry:

```json
{
  "loki": {
    "url": "http://10.43.8.34:80/loki"
  }
}
```

You will use:

- `<loki-url>/loki/api/v1/push` for ingestion
- `<loki-url>/loki/api/v1/query_range` for verification

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

The pipeline below tails a log file at `/var/log/my-workload/app.log` and
forwards each line to Loki over the `loki` exporter. The `filelog` receiver
acts as the tailer, and the `loki` exporter pushes into Loki's ingestion URL.
The `X-Scope-OrgID` header is required by Loki's multi-tenant API; use
`anonymous` for a single-tenant deployment.

```yaml
receivers:
  filelog/my-workload:
    include: [/var/log/my-workload/app.log]
    start_at: end
    operators:
      - type: add
        field: attributes.loki.attribute.labels
        value: job,log_file

exporters:
  loki:
    endpoint: "http://10.43.8.34:80/loki/loki/api/v1/push"
    headers:
      X-Scope-OrgID: anonymous
    default_labels_enabled:
      exporter: false
      job: true
    retry_on_failure:
      max_elapsed_time: 5m
    sending_queue:
      enabled: true
      queue_size: 1000

service:
  pipelines:
    logs:
      receivers: [filelog/my-workload]
      exporters: [loki]
```

Save it as:

```bash
sudo mkdir -p /etc/otelcol/config.d
sudo editor /etc/otelcol/config.d/otelcol_loki.yaml
```

Replace:

- `/var/log/my-workload/app.log` with the path to your workload's log file
- `http://10.43.8.34:80/loki/loki/api/v1/push` with your actual Loki ingress URL

## 4. Restart the collector

```bash
sudo snap restart opentelemetry-collector
```

If you want to confirm the collector started cleanly:

```bash
sudo snap logs opentelemetry-collector
```

## 5. Verify that logs reached Loki

Query Loki's LogQL API:

```bash
LOKI_URL=http://10.43.8.34:80/loki

curl -sG "$LOKI_URL/loki/api/v1/query_range" \
    --data-urlencode 'query={job="my-workload"}' \
    | jq
```

If the pipeline is working, the query returns log entries containing your
workload's log lines.

## HTTPS and private CAs

If either the workload's log file path is on a remote machine or the Loki
ingress URL uses TLS signed by a private CA, install that CA into the
machine trust store used by the snap.

See the CA-handling guidance in
[How to integrate COS Lite with uncharmed applications](integrating-cos-lite-with-uncharmed-applications).

## Adapting the filelog configuration

The example above uses a single static file path, but the same pattern works
for:

- glob patterns like `/var/log/my-workload/*.log`
- multiple include paths
- custom operators for parsing or transforming log lines (e.g. JSON parsing,
  regex extraction)
- journald input via the `journald` receiver

The important part is that the log pipeline ends with the `loki` exporter
pointing at:

```text
<loki-url>/loki/api/v1/push
```

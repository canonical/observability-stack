---
myst:
  html_meta:
    description: "Send logs to an external rsyslog server over TLS using the OpenTelemetry Collector Integrator charm with Juju secrets for secure credential management."
---

# How to send logs to non-charmed backends

The [OpenTelemetry Collector Integrator](https://github.com/canonical/opentelemetry-collector-integrator-operator) charm enables exporting telemetry from the charmed OpenTelemetry Collector to non-charmed backends. It acts as a configuration add-on that injects arbitrary exporter configurations, backed by Juju secrets.

This removes the need for [Prometheus federation](https://prometheus.io/docs/prometheus/latest/federation/) or similar other solutions.

This guide walks through sending logs to an external rsyslog server over TLS, demonstrating how the Integrator handles sensitive material like certificates through its secret templating system. The general approach here can be used with other backends.

```{important}
Available components (exporters, receivers, processors) depend on the OpenTelemetry Collector build compiled by Canonical. Check the [manifest-additions.yaml](https://github.com/canonical/opentelemetry-collector-rock) in the opentelemetry-collector-rock repository for your version to confirm what's included.
```

## Architecture overview

```{mermaid}
graph LR

subgraph Juju model
  app --- opentelemetry-collector
  opentelemetry-collector-integrator ---|"external-config"| opentelemetry-collector
end

opentelemetry-collector -.-|"syslog/rfc5424"| non-charmed[Non-charmed e.g. rsyslog]

juju-config@{ shape: braces, label: "Admin config<br> for rsyslog" } -.->|juju config\nconfig_yaml| opentelemetry-collector-integrator
juju-action@{ shape: braces, label: "Optional secrets<br> for rsyslog" } -.->|juju run\ncreate-secret| opentelemetry-collector-integrator
```

The Integrator injects a syslog exporter and a transform processor into the Collector's logs pipeline. Once the `external-config` integration is established, the Collector automatically merges the injected configuration and begins forwarding logs.

## Prerequisites

- A Juju controller and model on a machine cloud (for example, LXD)
- The `ubuntu` charm deployed in the model
- The `opentelemetry-collector` charm deployed as a subordinate of `ubuntu`.  This guide names the charm `otelcol` for short.
- An external rsyslog server reachable from the Juju machines, configured to accept TLS connections on port `6514`
- TLS certificate material for mutual TLS: CA certificate, client certificate, and client key
- `juju` CLI version 3.6 or later

```{note}
This guide uses the machine (VM) variant of the charms. For Kubernetes, replace `opentelemetry-collector` with `opentelemetry-collector-k8s`.
```

## Step 1: Deploy the OpenTelemetry Collector Integrator

Deploy the Integrator charm into the same model where `otelcol` is running:

```bash
juju deploy opentelemetry-collector-integrator otelcol-integrator --channel latest/edge
```

Wait for it to settle:

```bash
juju status --watch 2s
```

The Integrator enters `blocked` status until you provide a valid configuration with at least one pipeline enabled.

## Step 2: Create a Juju secret with TLS certificates

The Integrator manages secrets through a dedicated action. Certificate files must be base64-encoded because the Juju CLI does not preserve newlines in multi-line values.

Create the secret:

```bash
juju run otelcol-integrator/leader create-secret \
    name=rsyslog-tls \
    cafile="$(cat ca.crt | base64 -w0)" \
    certfile="$(cat client.crt | base64 -w0)" \
    keyfile="$(cat client.key | base64 -w0)"
```

The output includes the secret identifier:

```
keys: cafile,certfile,keyfile
secret-id: secret://a1b2c3d4-e5f6-7890-abcd-ef1234567890/csecr3t1d2k3y4l5
```

Save this `secret-id` value. You will use it in the next step to build secret reference URIs.

## Step 3: Create the exporter configuration

Create a file named `syslog-tls-exporter.yaml` with the following content. Replace the placeholder values with your rsyslog endpoint and the `secret-id` from Step 2:

```yaml
processors:
  transform/logs-to-syslog:
    log_statements:
      - context: log
        statements:
          - set(time, observed_time)
          - set(attributes["priority"], 14)
          - set(attributes["hostname"], body)
          - replace_pattern(attributes["hostname"], "^\\S+\\s+(\\S+)\\s+[\\s\\S]*$", "$1")
          - set(attributes["appname"], body)
          - replace_pattern(attributes["appname"], "^\\S+\\s+\\S+\\s+([^:\\[]+).*$", "$1")
          - set(attributes["message"], body)
          - replace_pattern(attributes["message"], "^\\S+\\s+\\S+\\s+\\S+(?:\\[\\d+\\])?:\\s*", "")

exporters:
  syslog/rsyslog:
    endpoint: your-rsyslog-server.example.com
    port: 6514
    network: tcp
    protocol: rfc5424
    tls:
      ca_file: "secret://a1b2c3d4-e5f6-7890-abcd-ef1234567890/csecr3t1d2k3y4l5/cafile?render=file"
      cert_file: "secret://a1b2c3d4-e5f6-7890-abcd-ef1234567890/csecr3t1d2k3y4l5/certfile?render=file"
      key_file: "secret://a1b2c3d4-e5f6-7890-abcd-ef1234567890/csecr3t1d2k3y4l5/keyfile?render=file"
```

```{dropdown} Configuration explained

**Transform processor** (`transform/logs-to-syslog`): The syslog exporter reads message content and metadata from log attributes — not from the log body directly. Since the Collector's filelog receiver passes raw syslog lines as the body (e.g., `2026-04-30T15:38:18+00:00 myhost myapp[123]: Hello world`), this processor parses each line to populate those attributes. The statements execute in order:

1. `set(time, observed_time)` — overwrites the log timestamp with the time the Collector received the log. The filelog receiver sets `time` to zero (epoch) because it does not parse the syslog timestamp from the body.
2. `set(attributes["priority"], 14)` — sets a static syslog priority (facility 1 × 8 + severity 6 = user-level informational).
3. `set(attributes["hostname"], body)` + `replace_pattern(…, "^\\S+\\s+(\\S+)\\s+[\\s\\S]*$", "$1")` — copies the body into the attribute, then strips everything except the second whitespace-delimited field (the hostname).
4. `set(attributes["appname"], body)` + `replace_pattern(…, "^\\S+\\s+\\S+\\s+([^:\\[]+).*$", "$1")` — same technique: keeps only the third field up to `:` or `[` (the syslog tag, e.g., `test-otelcol`).
5. `set(attributes["message"], body)` + `replace_pattern(…, "^\\S+\\s+\\S+\\s+\\S+(?:\\[\\d+\\])?:\\s*", "")` — strips the timestamp, hostname, and tag prefix, leaving only the message payload.

With a fixed priority of `14`, all logs appear as informational in rsyslog regardless of their actual severity. To preserve severity, replace the static value with conditional OTTL statements that map OpenTelemetry's `severity_number` (1–24) to syslog priority values. Syslog priority is calculated as `facility × 8 + severity` — see [RFC 5424 §6.2.1](https://datatracker.ietf.org/doc/html/rfc5424#section-6.2.1) for the full table.

This processor is applied to all logs in the pipeline, not only those routed to the syslog exporter. The additional attributes do not cause errors in other exporters (such as Loki or OTLP).

**Syslog exporter** (`syslog/rsyslog`):
- `endpoint`: hostname or IP of the rsyslog server (no protocol prefix)
- `port`: TCP port (6514 is the IANA standard for syslog over TLS)
- `network`: must be `tcp` for TLS
- `protocol`: `rfc5424` (modern syslog standard)
- `tls`: references to the Juju secret using the `?render=file` directive — the Collector writes each certificate to disk with restricted permissions and substitutes the file path

The secret URI format is: `<secret-id>/<key>?render=<type>`, where `<secret-id>` is the full value returned by the `create-secret` action, `<key>` is one of the keys you stored in the secret, and `<type>` is `file` (for certificates written to disk) or `inline` (for values substituted directly in the config text).
```

## Step 4: Apply the configuration

Configure the Integrator with the exporter YAML and enable the logs pipeline:

```bash
juju config otelcol-integrator \
    config_yaml=@syslog-tls-exporter.yaml \
    logs_pipeline=true
```

Verify the Integrator reaches `active` status:

```bash
juju status otelcol-integrator
```

You should see:

```
App                 Version  Status   Scale  Charm                               Channel        Rev  Exposed  Message
otelcol-integrator           active       1  opentelemetry-collector-integrator  latest/edge      3  no       Pipelines: logs configured
```

If the charm shows `blocked`, check `juju debug-log --include otelcol-integrator --replay` for validation errors in your YAML or pipeline configuration.

## Step 5: Integrate the Collector with the Integrator

Establish the `external-config` integration:

```bash
juju integrate otelcol:external-config otelcol-integrator:external-config
```

Once the integration is established, the Integrator shares the configuration and grants access to the Juju secret. The Collector automatically:

1. Retrieves the secret content
2. Writes certificate files to disk (for `?render=file` references)
3. Merges the exporter and processor into its logs pipeline
4. Reloads its configuration

```{note}
The `otelcol` application  may remain in `blocked` status because the `external-config` integration does not satisfy the charm's primary outbound integration requirements (such as `send-loki-logs` or `send-otlp`). This does not prevent the external exporter from functioning — logs are still forwarded to rsyslog.
```

Verify the integration is established:

```bash
juju status --relations
```

You should see an `external-config` integration between `otelcol` and `otelcol-integrator`.

```{warning}
If you are testing with rsyslog running on the **same machine** as the Collector (for example, using `127.0.0.1` as the endpoint), you must exclude the rsyslog output file from the Collector's filelog receiver to avoid an infinite log loop. Set the `path_exclude` configuration option on the `otelcol` charm to include the rsyslog log path (for example, `/var/log/otelcol-remote.log*`).
```

## Step 6: Verify logs are reaching rsyslog

On your external rsyslog server, start watching the log output:

```bash
sudo tail -f /var/log/otelcol-remote.log
```

Generate a test log using the system logger:

```bash
juju ssh ubuntu/0 "logger -t test-otelcol 'Hello from OtelCol Integrator'"
```

Within a few seconds, you should see the message appear in your rsyslog output file:

```
2026-04-30T16:27:32.071582Z juju-ec9344-0 test-otelcol Hello from OtelCol Integrator via syslog :)
```

## Cross-model relations

If your Integrator and Collector are deployed in different Juju models, use cross-model relations (CMR):

```bash
# From the Integrator's model, offer the endpoint:
juju offer otelcol-integrator:external-config

# From the Collector's model, consume and integrate:
juju consume <controller>:admin/<integrator-model>.otelcol-integrator
juju integrate otelcol:external-config otelcol-integrator:external-config
```

For more details, see the [Juju cross-model relations documentation](https://documentation.ubuntu.com/juju/3.6/howto/manage-relations/#add-a-cross-model-relation).

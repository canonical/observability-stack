---
myst:
  html_meta:
    description: "Send logs to an external rsyslog server over TLS using the OpenTelemetry Collector Integrator charm with Juju secrets for secure credential management."
---

# How to send logs to non-charmed backends

The [OpenTelemetry Collector Integrator](https://github.com/canonical/opentelemetry-collector-integrator-operator) charm enables you to export telemetry from charmed OpenTelemetry Collector to non-charmed backends. It acts as a configuration add-on that injects arbitrary exporter configurations, backed by Juju secrets.
This obviates the need for [Prometheus federation](https://prometheus.io/docs/prometheus/latest/federation/) or similar other solutions.

```{important}
Available components (exporters, receivers, processors) depend on the OpenTelemetry Collector build compiled by Canonical. Check the [manifest-additions.yaml](https://github.com/canonical/opentelemetry-collector-rock/blob/main/0.130.1/manifest.yaml) in the opentelemetry-collector-rock repository for your version to confirm what's included.
```

## Architecture overview

```{mermaid}
graph LR

subgraph Juju model
  app --- opentelemetry-collector
  opentelemetry-collector-integrator ---|"external-config"| opentelemetry-collector
end

opentelemetry-collector -.-|"syslog/rfc5424"| non-charmed[Non-charmed e.g. rsyslog]

juju-config@{ shape: braces, label: "Admin config<br> for rsyslog" } -.->|juju config| opentelemetry-collector-integrator
juju-action@{ shape: braces, label: "Optional secrets<br> for rsyslog" } -.->|juju run| opentelemetry-collector-integrator
```

The admin needs to provide a valid opentelemetry exporter config (example: [syslog](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/syslogexporter)). Once the `external-config` integration between opentelemetry-collector and the integrator charms is established,
opentelemetry-collector will merge the injected configuration and begin forwarding logs.

The integrator charm may be related [cross-model](https://documentation.ubuntu.com/juju/3.6/howto/manage-relations/#add-a-cross-model-relation).

TODO: add a link to the tutorial.

## Create relevant secrets

The Integrator manages secrets through a dedicated action. Secrets with characters not accepted by the Juju CLI (such as new-line), must be base64-encoded.

To create a secret, use the `create-secret` action, for example:

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

## Create the exporter configuration

Use the `secret-id` in the config you pass to the integrator. For example:

```yaml
# syslog-exporter.yaml
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

The secret URI format is: `<secret-id>/<key>?render=<type>`, where `<secret-id>` is the full value returned by the `create-secret` action, `<key>` is one of the keys you stored in the secret, and `<type>` is `file` (for certificates written to disk) or `inline` (for values substituted directly in the config text).

## Apply the configuration

Configure the Integrator with the exporter YAML and enable the logs pipeline:

```bash
juju config otelcol-integrator \
    config_yaml=@syslog-exporter.yaml \
    logs_pipeline=true

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

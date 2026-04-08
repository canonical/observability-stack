---
myst:
  html_meta:
    description: "Practical how-to guides for operating Canonical Observability Stack, including migration, integration, telemetry configuration, and troubleshooting tasks."
---

(how-to)=

# How-to guides

These guides accompany you through the complete COS stack operations life cycle.

```{note}
If you are looking for instructions on how to get started with COS Lite, see
{ref}`the tutorial section <tutorial>`.
```

## Validating

These guides will help validating new and existing deployments.

```{toctree}
:maxdepth: 1

Validate COS deployment <operations/validate-cos-deployment>
```

## Migrating

These guides till assist existing users of other observability stacks offered by
Canonical in migrating to COS Lite or the full COS.

```{toctree}
:maxdepth: 1

Cross-track upgrade instructions <install-and-maintain/upgrade>
Migrate from LMA to COS Lite <install-and-maintain/migrate-lma-to-cos-lite>
Migrate from Grafana Agent to OpenTelemetry Collector <install-and-maintain/migrate-grafana-agent-to-otelcol>
```

## Configuring

Once COS has been deployed, the next natural step would be to integrate your charms and workloads
with COS to actually observe them.

```{toctree}
:maxdepth: 1

Evaluate telemetry volume <operations/evaluate-telemetry-volume>
Add tracing to COS Lite <install-and-maintain/add-tracing-to-cos-lite>
Add alert rules <integrations/adding-alert-rules>
Configure scrape jobs <integrations/configure-scrape-jobs>
Expose a metrics endpoint <integrations/exposing-a-metrics-endpoint>
Integrate COS Lite with uncharmed applications <install-and-maintain/integrating-cos-lite-with-uncharmed-applications>
Disable built-in charm alert rules <operations/disable-charmed-rules>
Testing with Minio <install-and-maintain/deploy-s3-integrator-and-minio>
Configure TLS encryption <install-and-maintain/configure-tls-encryption>
Selectively drop telemetry using scrape config <operations/selectively-drop-telemetry-scrape-config>
Selectively drop telemetry using opentelemetry-collector <operations/selectively-drop-telemetry-otelcol>
Tier OpenTelemetry Collector with different pipelines per data stream <integrations/tiered-otelcols>
```

## Troubleshooting

During continuous operations, you might sometimes run into issues that you need to resolve. These
how-to guides will assist you in troubleshooting COS in an effective manner.

```{toctree}
:maxdepth: 1

Troubleshooting <troubleshooting>
```

## Configuration

In this part of the tutorial you will learn how to make COS automatically sync
the alert rules of your git repository to your metrics backend using the COS Configuration
charm.

```{toctree}
:maxdepth: 1

Sync alert rules from Git <operations/sync-alert-rules-from-git>
```

## Instrumentation

Bridge the gap between COS Lite running in Kubernetes and your application
running on a machine. Discover how to collect telemetry data from your charmed
application using the Grafana Agent machine charm.

```{toctree}
:maxdepth: 1

Instrument machine charms <integrations/instrument-machine-charms>
```

## Redaction

By implementing a solid redaction strategy you can mitigate the risk of unwanted data leaks. This helps to comply with information security policies which outline the need for redacting personally identifiable information (PII), credentials, and other sensitive data.

```{toctree}
:maxdepth: 1

Redact sensitive data <operations/redact-sensitive-data>
```
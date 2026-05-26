(integrate)=

# Integrate

Connect your charmed and uncharmed workloads to COS.

## Connect workloads

Bring charmed and uncharmed workloads into the COS telemetry pipeline.

```{toctree}
:maxdepth: 1

Integrate COS Lite with uncharmed applications <integrating-cos-lite-with-uncharmed-applications>
Expose a metrics endpoint <exposing-a-metrics-endpoint>
Configure scrape jobs <configure-scrape-jobs>
Monitor SSL certificates with blackbox exporter <monitor-ssl-certificates-with-blackbox-exporter>
Instrument machine charms <instrument-machine-charms>
Use the Loki HTTP API <use-loki-http-api>
Use Catalogue <use-catalogue>
Send metrics to Mimir <send-metrics-to-mimir>
```

## Extend the pipeline

Layer additional data streams, tracing, and alerting onto an existing
deployment.

```{toctree}
:maxdepth: 1

Send telemetry to external backends <send-telemetry-to-external-backends>
Tier OpenTelemetry Collector with different pipelines per data stream <tiered-otelcols>
Correlate node-exporter metrics with multiple co-located VM charms <correlate-colocated>
Add tracing to COS Lite <add-tracing-to-cos-lite>
Manually enable a Tempo HA tracing receiver <manually-enable-tempo-ha-tracing-receiver>
Add alert rules <adding-alert-rules>
Integrate Alertmanager with external receivers <integrate-alertmanager-receivers>
Set up SLOs with Sloth <set-up-slos-with-sloth>
Sync alert rules from a git repo <sync-alert-rules-from-git-repo>
```

## Test & validate integrations

Validate local object-storage integrations or wire existing storage into Mimir.

```{toctree}
:maxdepth: 1

Testing with Minio <deploy-s3-integrator-and-minio>
Configure object storage for Mimir <configure-object-storage-for-mimir>
```

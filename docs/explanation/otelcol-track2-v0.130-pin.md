# Opentelemetry-collector pinned to v0.130 in tracks 2 and 3

## Context

The opentelemetry-collector charms (K8s and VM) use the [opentelemetry-collector-contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib) as their workload, which is rapidly evolving. The contrib repo maintainers decided to drop support for the `lokiexporter` in [release v0.131.0](https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.131.0), stating users can migrate to the OTLP exporters.

## Why does this only apply to tracks 2 and 3?

The logging integrations for the `opentelemetry-collector` charms in tracks 2 and 3 rely on  `lokiexporter` to send logs to Loki push API endpoints. Loki only recently received upstream support for an OTLP endpoint, and migrating to an OTLP-first ecosystem in COS began in 26.04. The objective is to have support for OTLP ecosystem-wide by the end of 26.10 and to deprecate Loki Push API feature (`logging` endpoint) in track 3. Support will then be fully dropped in track 4, and the `opentelemetry-collector` charms will no longer be pinned to `v0.130`.

---
myst:
  html_meta:
    description: "Browse the complete reference for Canonical Observability Stack charms, rocks and snaps, including component roles, deployment-relevant details and registry locations."
---

# COS components

This page describes the charms, rocks, and snaps that make up the current **Observability 3.0** release (comprising both COS 3.0 and COS Lite 3.0). The `LTS` column indicates whether a component is part of the LTS set for this release; both LTS and non-LTS charms follow the [release policy](../release-policy) support windows; see that page for the end of support dates for each. Use the `Track` column to pick the right channel when deploying (e.g. `juju deploy <charm> --channel <track>/stable`).

## COS charms

| Charm                                                                    | LTS | Substrate | Workload version | Track | Contributing                                                                                                                                              |
| ------------------------------------------------------------------------ | --- | --------- | ---------------- | ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Alertmanager](https://charmhub.io/alertmanager-k8s)                     | Yes | K8s       | 0.31             | 0.31  | [Source](https://github.com/canonical/alertmanager-k8s-operator), [issues](https://github.com/canonical/alertmanager-k8s-operator/issues)                 |
| [Catalogue](https://charmhub.io/catalogue-k8s)                           | Yes | K8s       | 3.0              | 3.0   | [Source](https://github.com/canonical/catalogue-k8s-operator), [issues](https://github.com/canonical/catalogue-k8s-operator/issues)                       |
| [Grafana](https://charmhub.io/grafana-k8s)                               | Yes | K8s       | 12.4             | 12.4  | [Source](https://github.com/canonical/grafana-k8s-operator), [issues](https://github.com/canonical/grafana-k8s-operator/issues)                           |
| [Loki Coordinator](https://charmhub.io/loki-coordinator-k8s)             | Yes | K8s       | 1.27 (`nginx`)   | 3.7   | [Source](https://github.com/canonical/loki-operators/tree/main/coordinator), [issues](https://github.com/canonical/loki-operators/issues)                 |
| [Loki Worker](https://charmhub.io/loki-worker-k8s)                       | Yes | K8s       | 3.7              | 3.7   | [Source](https://github.com/canonical/loki-operators/tree/main/worker), [issues](https://github.com/canonical/loki-operators/issues)                      |
| [Mimir Coordinator](https://charmhub.io/mimir-coordinator-k8s)           | Yes | K8s       | 1.27 (`nginx`)   | 2.17  | [Source](https://github.com/canonical/mimir-operators/tree/main/coordinator), [issues](https://github.com/canonical/mimir-operators/issues)               |
| [Mimir Worker](https://charmhub.io/mimir-worker-k8s)                     | Yes | K8s       | 3.0              | 2.17  | [Source](https://github.com/canonical/mimir-operators/tree/main/worker), [issues](https://github.com/canonical/mimir-operators/issues)                    |
| [S3 Integrator](https://charmhub.io/s3-integrator)                       | Yes | Any       | -                | 2     | [Source](https://github.com/canonical/s3-integrator), [issues](https://github.com/canonical/s3-integrator/issues)                                         |
| [Self-signed Certificates](https://charmhub.io/self-signed-certificates) | Yes | Any       | -                | 1     | [Source](https://github.com/canonical/self-signed-certificates-operator), [issues](https://github.com/canonical/self-signed-certificates-operator/issues) |
| [Tempo Coordinator](https://charmhub.io/tempo-coordinator-k8s)           | Yes | K8s       | 1.27 (`nginx`)   | 2.10  | [Source](https://github.com/canonical/tempo-coordinator-k8s-operator), [issues](https://github.com/canonical/tempo-coordinator-k8s-operator/issues)       |
| [Tempo Worker](https://charmhub.io/tempo-worker-k8s)                     | Yes | K8s       | 2.10             | 2.10  | [Source](https://github.com/canonical/tempo-worker-k8s-operator), [issues](https://github.com/canonical/tempo-worker-k8s-operator/issues)                 |
| [Traefik](https://charmhub.io/traefik-k8s)                               | Yes | K8s       | 2.11             | 2.11  | [Source](https://github.com/canonical/traefik-k8s-operator), [issues](https://github.com/canonical/traefik-k8s-operator/issues)                           |

## COS Lite charms

| Charm                                                                    | LTS | Substrate | Workload version | Track | Contributing                                                                                                                                              |
| ------------------------------------------------------------------------ | --- | --------- | ---------------- | ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Alertmanager](https://charmhub.io/alertmanager-k8s)                     | Yes | K8s       | 0.31             | 0.31  | [Source](https://github.com/canonical/alertmanager-k8s-operator), [issues](https://github.com/canonical/alertmanager-k8s-operator/issues)                 |
| [Catalogue](https://charmhub.io/catalogue-k8s)                           | Yes | K8s       | 3.0              | 3.0   | [Source](https://github.com/canonical/catalogue-k8s-operator), [issues](https://github.com/canonical/catalogue-k8s-operator/issues)                       |
| [Grafana](https://charmhub.io/grafana-k8s)                               | Yes | K8s       | 12.4             | 12.4  | [Source](https://github.com/canonical/grafana-k8s-operator), [issues](https://github.com/canonical/grafana-k8s-operator/issues)                           |
| [Loki](https://charmhub.io/loki-k8s)                                     | Yes | K8s       | 3.7              | 3.7   | [Source](https://github.com/canonical/loki-k8s-operator), [issues](https://github.com/canonical/loki-k8s-operator/issues)                                 |
| [Prometheus](https://charmhub.io/prometheus-k8s)                         | Yes | K8s       | 3.11             | 3.11  | [Source](https://github.com/canonical/prometheus-k8s-operator), [issues](https://github.com/canonical/prometheus-k8s-operator/issues)                     |
| [Self-signed Certificates](https://charmhub.io/self-signed-certificates) | Yes | Any       | -                | 1     | [Source](https://github.com/canonical/self-signed-certificates-operator), [issues](https://github.com/canonical/self-signed-certificates-operator/issues) |
| [Traefik](https://charmhub.io/traefik-k8s)                               | Yes | K8s       | 2.11             | 2.11  | [Source](https://github.com/canonical/traefik-k8s-operator), [issues](https://github.com/canonical/traefik-k8s-operator/issues)                           |

## Peripheral charms

| Charm                                                                                        | LTS | Substrate | Workload version | Track | Contributing                                                                                                                                                                  |
| -------------------------------------------------------------------------------------------- | --- | --------- | ---------------- | ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Avalanche](https://charmhub.io/avalanche-k8s)                                               | No  | K8s       | -                | 0.7   | [Source](https://github.com/canonical/avalanche-k8s-operator), [issues](https://github.com/canonical/avalanche-k8s-operator/issues)                                           |
| [Blackbox Exporter](https://charmhub.io/blackbox-exporter-k8s)                               | Yes | K8s       | 0.28             | 0.28  | [Source](https://github.com/canonical/blackbox-exporter-k8s-operator), [issues](https://github.com/canonical/blackbox-exporter-k8s-operator/issues)                           |
| [Blackbox Exporter](https://charmhub.io/blackbox-exporter)                                   | Yes | Machines  | 0.28             | 0.28  | [Source](https://github.com/canonical/blackbox-exporter-operator), [issues](https://github.com/canonical/blackbox-exporter-operator/issues)                                   |
| [COS Configuration](https://charmhub.io/cos-configuration-k8s)                               | Yes | K8s       | 3.6              | 3.0   | [Source](https://github.com/canonical/cos-configuration-k8s-operator), [issues](https://github.com/canonical/cos-configuration-k8s-operator/issues)                           |
| [COS Proxy](https://charmhub.io/cos-proxy)                                                   | Yes | Machines  | -                | 3.0   | [Source](https://github.com/canonical/cos-proxy-operator), [issues](https://github.com/canonical/cos-proxy-operator/issues)                                                   |
| [Grafana Agent](https://charmhub.io/grafana-agent)                                           | No  | Machines  | 0.44             | 0.44  | [Source](https://github.com/canonical/grafana-agent-operator), [issues](https://github.com/canonical/grafana-agent-operator/issues)                                           |
| [Grafana Agent](https://charmhub.io/grafana-agent-k8s)                                       | No  | K8s       | 0.40             | 0.40  | [Source](https://github.com/canonical/grafana-agent-k8s-operator), [issues](https://github.com/canonical/grafana-agent-k8s-operator/issues)                                   |
| [Grafana Cloud Integrator](https://charmhub.io/grafana-cloud-integrator)                     | No  | Any       | -                | 3.0   | [Source](https://github.com/canonical/grafana-cloud-integrator), [issues](https://github.com/canonical/grafana-cloud-integrator/issues)                                       |
| [k6](https://charmhub.io/k6-k8s)                                                             | No  | K8s       | 1.7              | 1.7   | [Source](https://github.com/canonical/k6-k8s-operator), [issues](https://github.com/canonical/k6-k8s-operator/issues)                                                         |
| [Litmus Auth](https://charmhub.io/litmus-auth-k8s)                                           | No  | K8s       | 3.29             | 3.29  | [Source](https://github.com/canonical/litmus-operators/tree/main/auth), [issues](https://github.com/canonical/litmus-operators/issues)                                        |
| [Litmus Backend](https://charmhub.io/litmus-backend-k8s)                                     | No  | K8s       | 3.29             | 3.29  | [Source](https://github.com/canonical/litmus-operators/tree/main/backend), [issues](https://github.com/canonical/litmus-operators/issues)                                     |
| [Litmus Chaoscenter](https://charmhub.io/litmus-chaoscenter-k8s)                             | No  | K8s       | 3.29             | 3.29  | [Source](https://github.com/canonical/litmus-operators/tree/main/chaoscenter), [issues](https://github.com/canonical/litmus-operators/issues)                                 |
| [Litmus Infrastructure](https://charmhub.io/litmus-infrastructure-k8s)                       | No  | K8s       | 3.29             | 3.29  | [Source](https://github.com/canonical/litmus-operators/tree/main/infrastructure), [issues](https://github.com/canonical/litmus-operators/issues)                              |
| [Opentelemetry Collector](https://charmhub.io/opentelemetry-collector-k8s)                   | Yes | K8s       | 0.130            | 0.130 | [Source](https://github.com/canonical/opentelemetry-collector-k8s-operator), [issues](https://github.com/canonical/opentelemetry-collector-k8s-operator/issues)               |
| [Opentelemetry Collector](https://charmhub.io/opentelemetry-collector)                       | Yes | Machines  | 0.130            | 0.130 | [Source](https://github.com/canonical/opentelemetry-collector-operator), [issues](https://github.com/canonical/opentelemetry-collector-operator/issues)                       |
| [Opentelemetry Collector Integrator](https://charmhub.io/opentelemetry-collector-integrator) | Yes | Any       | -                | 3.0   | [Source](https://github.com/canonical/opentelemetry-collector-integrator-operator), [issues](https://github.com/canonical/opentelemetry-collector-integrator-operator/issues) |
| [OTel eBPF Profiler](https://charmhub.io/otel-ebpf-profiler)                                 | No  | Machines  | 0.147            | 0.147 | [Source](https://github.com/canonical/otel-ebpf-profiler-operator), [issues](https://github.com/canonical/otel-ebpf-profiler-operator/issues)                                 |
| [Parca Agent](https://charmhub.io/parca-agent)                                               | No  | Machines  | 0.35             | 0.35  | [Source](https://github.com/canonical/parca-agent-operator), [issues](https://github.com/canonical/parca-agent-operator/issues)                                               |
| [Parca](https://charmhub.io/parca-k8s)                                                       | No  | K8s       | 0.27             | 0.27  | [Source](https://github.com/canonical/parca-k8s-operator), [issues](https://github.com/canonical/parca-k8s-operator/issues)                                                   |
| [Parca Scrape Target](https://charmhub.io/parca-scrape-target)                               | No  | Any       | -                | 3.0   | [Source](https://github.com/canonical/parca-scrape-target-operator), [issues](https://github.com/canonical/parca-scrape-target-operator/issues)                               |
| [Polar Signals Cloud Integrator](https://charmhub.io/polar-signals-cloud-integrator)         | No  | Any       | -                | 3.0   | [Source](https://github.com/canonical/polar-signals-cloud-integrator-operator), [issues](https://github.com/canonical/polar-signals-cloud-integrator-operator/issues)         |
| [Prometheus Pushgateway](https://charmhub.io/prometheus-pushgateway-k8s)                     | Yes | K8s       | 1.11             | 1.11  | [Source](https://github.com/canonical/prometheus-pushgateway-k8s-operator), [issues](https://github.com/canonical/prometheus-pushgateway-k8s-operator/issues)                 |
| [Prometheus Scrape Config](https://charmhub.io/prometheus-scrape-config-k8s)                 | Yes | Any       | -                | 3.0   | [Source](https://github.com/canonical/prometheus-scrape-config-k8s-operator), [issues](https://github.com/canonical/prometheus-scrape-config-k8s-operator/issues)             |
| [Prometheus Scrape Target](https://charmhub.io/prometheus-scrape-target-k8s)                 | Yes | Any       | -                | 3.0   | [Source](https://github.com/canonical/prometheus-scrape-target-k8s-operator), [issues](https://github.com/canonical/prometheus-scrape-target-k8s-operator/issues)             |
| [Pyroscope Coordinator](https://charmhub.io/pyroscope-coordinator-k8s)                       | No  | K8s       | 1.27 (`nginx`)   | 1.18  | [Source](https://github.com/canonical/pyroscope-operators/tree/main/coordinator), [issues](https://github.com/canonical/pyroscope-operators/issues)                           |
| [Pyroscope Worker](https://charmhub.io/pyroscope-worker-k8s)                                 | No  | K8s       | 1.18             | 1.18  | [Source](https://github.com/canonical/pyroscope-operators/tree/main/worker), [issues](https://github.com/canonical/pyroscope-operators/issues)                                |
| [Script Exporter](https://charmhub.io/script-exporter)                                       | Yes | Machines  | 3.2              | 3.2   | [Source](https://github.com/canonical/script-exporter-operator), [issues](https://github.com/canonical/script-exporter-operator/issues)                                       |
| [SNMP Exporter](https://charmhub.io/prometheus-snmp-exporter)                                | Yes | Machines  | 0.30             | 0.24  | [Source](https://github.com/canonical/snmp-exporter-operator), [issues](https://github.com/canonical/snmp-exporter-operator/issues)                                           |

## Rocks

| Rock                                                                                            | Contributing                                                                                                                                        |
| ----------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`ubuntu/alertmanager`](https://hub.docker.com/r/ubuntu/alertmanager)                           | [Source](https://github.com/canonical/alertmanager-rock), [issues](https://github.com/canonical/alertmanager-rock/issues)                           |
| [`ubuntu/blackbox-exporter`](https://hub.docker.com/r/ubuntu/blackbox-exporter)                 | [Source](https://github.com/canonical/blackbox-exporter-rock), [issues](https://github.com/canonical/blackbox-exporter-rock/issues)                 |
| [`ubuntu/git-sync`](https://hub.docker.com/r/ubuntu/git-sync)                                   | [Source](https://github.com/canonical/git-sync-rock), [issues](https://github.com/canonical/git-sync-rock/issues)                                   |
| [`ubuntu/grafana-agent`](https://hub.docker.com/r/ubuntu/grafana-agent)                         | [Source](https://github.com/canonical/grafana-agent-rock), [issues](https://github.com/canonical/grafana-agent-rock/issues)                         |
| [`ubuntu/grafana`](https://hub.docker.com/r/ubuntu/grafana)                                     | [Source](https://github.com/canonical/grafana-rock), [issues](https://github.com/canonical/grafana-rock/issues)                                     |
| [`ubuntu/loki`](https://hub.docker.com/r/ubuntu/loki)                                           | [Source](https://github.com/canonical/loki-rock), [issues](https://github.com/canonical/loki-rock/issues)                                           |
| [`ubuntu/mimir`](https://hub.docker.com/r/ubuntu/mimir)                                         | [Source](https://github.com/canonical/mimir-rock), [issues](https://github.com/canonical/mimir-rock/issues)                                         |
| [`ubuntu/nginx`](https://hub.docker.com/r/ubuntu/nginx) | [Source](https://github.com/canonical/nginx-rock), [issues](https://github.com/canonical/nginx-rock/issues) |
| [`ubuntu/nginx-prometheus-exporter`](https://hub.docker.com/r/ubuntu/nginx-prometheus-exporter) | [Source](https://github.com/canonical/nginx-prometheus-exporter-rock), [issues](https://github.com/canonical/nginx-prometheus-exporter-rock/issues) |
| [`ubuntu/node-exporter`](https://hub.docker.com/r/ubuntu/node-exporter)                         | [Source](https://github.com/canonical/node-exporter-rock), [issues](https://github.com/canonical/node-exporter-rock/issues)                         |
| [`ubuntu/opentelemetry-collector`](https://hub.docker.com/r/ubuntu/opentelemetry-collector)     | [Source](https://github.com/canonical/opentelemetry-collector-rock), [issues](https://github.com/canonical/opentelemetry-collector-rock/issues)     |
| [`ubuntu/parca`](https://hub.docker.com/r/ubuntu/parca)                                         | [Source](https://github.com/canonical/parca-rock), [issues](https://github.com/canonical/parca-rock/issues)                                         |
| [`ubuntu/prometheus`](https://hub.docker.com/r/ubuntu/prometheus)       | [Source](https://github.com/canonical/prometheus-rock), [issues](https://github.com/canonical/prometheus-rock/issues)       |
| [`ubuntu/prometheus-pushgateway`](https://hub.docker.com/r/ubuntu/prometheus-pushgateway)       | [Source](https://github.com/canonical/prometheus-pushgateway-rock), [issues](https://github.com/canonical/prometheus-pushgateway-rock/issues)       |
| [`ghcr.io/canonical/s3proxy`](https://github.com/canonical/s3proxy-rock/pkgs/container/s3proxy) | [Source](https://github.com/canonical/s3proxy-rock), [issues](https://github.com/canonical/s3proxy-rock/issues)                                     |
| [`ubuntu/tempo`](https://hub.docker.com/r/ubuntu/tempo)                                         | [Source](https://github.com/canonical/tempo-rock), [issues](https://github.com/canonical/tempo-rock/issues)                                         |
| [`ubuntu/xk6`](https://hub.docker.com/r/ubuntu/xk6)                                             | [Source](https://github.com/canonical/xk6-rock), [issues](https://github.com/canonical/xk6-rock/issues)                                             |

## Snaps

| Snap                                                                    | Contributing                                                                                                                                    |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| [Blackbox Exporter](https://snapcraft.io/prometheus-blackbox-exporter)  | [Source](https://github.com/canonical/prometheus-blackbox-exporter-snap), [issues](https://github.com/canonical/prometheus-blackbox-exporter-snap/issues) |
| [Grafana Agent](https://snapcraft.io/grafana-agent)                     | [Source](https://github.com/canonical/grafana-agent-snap), [issues](https://github.com/canonical/grafana-agent-snap/issues)                     |
| [Node Exporter](https://snapcraft.io/node-exporter)                     | [Source](https://github.com/canonical/node-exporter-snap), [issues](https://github.com/canonical/node-exporter-snap/issues)                     |
| [OpenTelemetry Collector](https://snapcraft.io/opentelemetry-collector) | [Source](https://github.com/canonical/opentelemetry-collector-snap), [issues](https://github.com/canonical/opentelemetry-collector-snap/issues) |

## Reference pages

The following pages provide per-component reference material, including SLI definitions and workload-specific details.

```{toctree}
:maxdepth: 1

Alertmanager <alertmanager/index>
Grafana <grafana/index>
Loki <loki/index>
Mimir <mimir/index>
Prometheus <prometheus/index>
Tempo <tempo/index>
```

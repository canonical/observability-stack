---
myst:
  html_meta:
    description: "Browse the complete reference for Canonical Observability Stack charms, rocks and snaps, including component roles, deployment-relevant details and registry locations."
---

# COS components

## COS charms

| Charm                                                                    | Substrate | Workload version | Contributing                                                                                                                                              |
| ------------------------------------------------------------------------ | --------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Alertmanager](https://charmhub.io/alertmanager-k8s)                     | K8s       |                  | [Source](https://github.com/canonical/alertmanager-k8s-operator), [issues](https://github.com/canonical/alertmanager-k8s-operator/issues)                 |
| [Catalogue](https://charmhub.io/catalogue-k8s)                           | K8s       |                  | [Source](https://github.com/canonical/catalogue-k8s-operator), [issues](https://github.com/canonical/catalogue-k8s-operator/issues)                       |
| [Grafana](https://charmhub.io/grafana-k8s)                               | K8s       |                  | [Source](https://github.com/canonical/grafana-k8s-operator), [issues](https://github.com/canonical/grafana-k8s-operator/issues)                           |
| [Loki Coordinator](https://charmhub.io/loki-coordinator-k8s)             | K8s       |                  | [Source](https://github.com/canonical/loki-operators/tree/main/coordinator), [issues](https://github.com/canonical/loki-operators/issues)         |
| [Loki Worker](https://charmhub.io/loki-worker-k8s)                       | K8s       |                  | [Source](https://github.com/canonical/loki-operators/tree/main/worker), [issues](https://github.com/canonical/loki-operators/issues)                   |
| [Mimir Coordinator](https://charmhub.io/mimir-coordinator-k8s)           | K8s       |                  | [Source](https://github.com/canonical/mimir-operators/tree/main/coordinator), [issues](https://github.com/canonical/mimir-operators/issues)       |
| [Mimir Worker](https://charmhub.io/mimir-worker-k8s)                     | K8s       |                  | [Source](https://github.com/canonical/mimir-operators/tree/main/worker), [issues](https://github.com/canonical/mimir-operators/issues)                 |
| [S3 Integrator](https://charmhub.io/s3-integrator)                       | Any       |                  | [Source](https://github.com/canonical/s3-integrator), [issues](https://github.com/canonical/s3-integrator/issues)                                         |
| [Self-signed Certificates](https://charmhub.io/self-signed-certificates) | Any       |                  | [Source](https://github.com/canonical/self-signed-certificates-operator), [issues](https://github.com/canonical/self-signed-certificates-operator/issues) |
| [Tempo Coordinator](https://charmhub.io/tempo-coordinator-k8s)           | K8s       |                  | [Source](https://github.com/canonical/tempo-coordinator-k8s-operator), [issues](https://github.com/canonical/tempo-coordinator-k8s-operator/issues)       |
| [Tempo Worker](https://charmhub.io/tempo-worker-k8s)                     | K8s       |                  | [Source](https://github.com/canonical/tempo-worker-k8s-operator), [issues](https://github.com/canonical/tempo-worker-k8s-operator/issues)                 |
| [Traefik](https://charmhub.io/traefik-k8s)                               | K8s       |                  | [Source](https://github.com/canonical/traefik-k8s-operator), [issues](https://github.com/canonical/traefik-k8s-operator/issues)                           |

## COS Lite charms

| Charm                                                                    | Substrate | Workload version | Contributing                                                                                                                                              |
| ------------------------------------------------------------------------ | --------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Alertmanager](https://charmhub.io/alertmanager-k8s)                     | K8s       |                  | [Source](https://github.com/canonical/alertmanager-k8s-operator), [issues](https://github.com/canonical/alertmanager-k8s-operator/issues)                 |
| [Catalogue](https://charmhub.io/catalogue-k8s)                           | K8s       |                  | [Source](https://github.com/canonical/catalogue-k8s-operator), [issues](https://github.com/canonical/catalogue-k8s-operator/issues)                       |
| [Grafana](https://charmhub.io/grafana-k8s)                               | K8s       |                  | [Source](https://github.com/canonical/grafana-k8s-operator), [issues](https://github.com/canonical/grafana-k8s-operator/issues)                           |
| [Loki](https://charmhub.io/loki-k8s)                                     | K8s       |                  | [Source](https://github.com/canonical/loki-k8s-operator), [issues](https://github.com/canonical/loki-k8s-operator/issues)                                 |
| [Prometheus](https://charmhub.io/prometheus-k8s)                         | K8s       |                  | [Source](https://github.com/canonical/prometheus-k8s-operator), [issues](https://github.com/canonical/prometheus-k8s-operator/issues)                     |
| [Traefik](https://charmhub.io/traefik-k8s)                               | K8s       |                  | [Source](https://github.com/canonical/traefik-k8s-operator), [issues](https://github.com/canonical/traefik-k8s-operator/issues)                           |
| [Self-signed Certificates](https://charmhub.io/self-signed-certificates) | Any       |                  | [Source](https://github.com/canonical/self-signed-certificates-operator), [issues](https://github.com/canonical/self-signed-certificates-operator/issues) |

## Peripheral charms

| Charm                                                                        | Substrate | Workload version | Contributing                                                                                                                                                      |
| ---------------------------------------------------------------------------- | --------- | ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Blackbox Exporter](https://charmhub.io/blackbox-exporter-k8s)               | K8s       |                  | [Source](https://github.com/canonical/blackbox-exporter-k8s-operator), [issues](https://github.com/canonical/blackbox-exporter-k8s-operator/issues)               |
| [Blackbox Exporter](https://charmhub.io/blackbox-exporter)                   | Machine   |                  | [Source](https://github.com/canonical/blackbox-exporter-operator), [issues](https://github.com/canonical/blackbox-exporter-operator/issues)                       |
| [COS Configuration](https://charmhub.io/cos-configuration-k8s)               | K8s       |                  | [Source](https://github.com/canonical/cos-configuration-k8s-operator), [issues](https://github.com/canonical/cos-configuration-k8s-operator/issues)               |
| [COS Proxy](https://charmhub.io/cos-proxy)                                   | Machines  |                  | [Source](https://github.com/canonical/cos-proxy-operator), [issues](https://github.com/canonical/cos-proxy-operator/issues)                                       |
| [Grafana Agent](https://charmhub.io/grafana-agent-k8s)                       | K8s       |                  | [Source](https://github.com/canonical/grafana-agent-k8s-operator), [issues](https://github.com/canonical/grafana-agent-k8s-operator/issues)                       |
| [Grafana Agent](https://charmhub.io/grafana-agent)                           | Machines  |                  | [Source](https://github.com/canonical/grafana-agent-operator), [issues](https://github.com/canonical/grafana-agent-operator/issues)                               |
| [Opentelemetry Collector](https://charmhub.io/opentelemetry-collector-k8s)   | K8s       |                  | [Source](https://github.com/canonical/opentelemetry-collector-k8s-operator), [issues](https://github.com/canonical/opentelemetry-collector-k8s-operator/issues)   |
| [Opentelemetry Collector](https://charmhub.io/opentelemetry-collector)       | Machines  |                  | [Source](https://github.com/canonical/grafana-agent-operator), [issues](https://github.com/canonical/opentelemetry-collector-operator/issues)                     |
| [Karma](https://charmhub.io/karma-k8s)                                       | K8s       |                  | [Source](https://github.com/canonical/karma-k8s-operator), [issues](https://github.com/canonical/karma-k8s-operator/issues)                                       |
| [Karma Alertmanager Proxy](https://charmhub.io/karma-alertmanager-proxy-k8s) | K8s       |                  | [Source](https://github.com/canonical/karma-alertmanager-proxy-k8s-operator), [issues](https://github.com/canonical/karma-alertmanager-proxy-k8s-operator/issues) |
| [Prometheus Scrape Config](https://charmhub.io/prometheus-scrape-config-k8s) | Any       |                  | [Source](https://github.com/canonical/prometheus-scrape-config-k8s-operator), [issues](https://github.com/canonical/prometheus-scrape-config-k8s-operator/issues) |
| [Prometheus Scrape Target](https://charmhub.io/prometheus-scrape-target-k8s) | Any       |                  | [Source](https://github.com/canonical/prometheus-scrape-target-k8s-operator), [issues](https://github.com/canonical/prometheus-scrape-target-k8s-operator/issues) |
| [Script Exporter](https://charmhub.io/script-exporter)                       | Machines       |                  | [Source](https://github.com/canonical/script-exporter-operator), [issues](https://github.com/canonical/script-exporter-operator/issues)                           |
| SNMP Exporter                                                                | Machines  |                  | [Source](https://github.com/canonical/snmp-exporter-operator), [issues](https://github.com/canonical/snmp-exporter-operator/issues)                               |

## Rocks

| Rock                                                                                            | Contributing                                                                                                                                        |
| ----------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`ubuntu/alertmanager`](https://hub.docker.com/r/ubuntu/alertmanager)                           | [Source](https://github.com/canonical/alertmanager-rock), [issues](https://github.com/canonical/alertmanager-rock/issues)                           |
| [`ubuntu/blackbox-exporter`](https://hub.docker.com/r/ubuntu/blackbox-exporter)                 | [Source](https://github.com/canonical/blackbox-exporter-rock), [issues](https://github.com/canonical/blackbox-exporter-rock/issues)                 |
| `ghcr.io/canonical/git-sync`                                                                    | [Source](https://github.com/canonical/git-sync-rock), [issues](https://github.com/canonical/git-sync-rock/issues)                                   |
| [`ubuntu/grafana-agent`](https://hub.docker.com/r/ubuntu/grafana-agent)                         | [Source](https://github.com/canonical/grafana-agent-rock), [issues](https://github.com/canonical/grafana-agent-rock/issues)                         |
| [`ubuntu/grafana`](https://hub.docker.com/r/ubuntu/grafana)                                     | [Source](https://github.com/canonical/grafana-rock), [issues](https://github.com/canonical/grafana-rock/issues)                                     |
| [`ubuntu/karma`](https://hub.docker.com/r/ubuntu/karma)                                         | [Source](https://github.com/canonical/karma-rock), [issues](https://github.com/canonical/karma-rock/issues)                                         |
| [`ubuntu/loki`](https://hub.docker.com/r/ubuntu/loki)                                           | [Source](https://github.com/canonical/loki-rock), [issues](https://github.com/canonical/loki-rock/issues)                                           |
| [`ubuntu/mimir`](https://hub.docker.com/r/ubuntu/mimir)                                         | [Source](https://github.com/canonical/mimir-rock), [issues](https://github.com/canonical/mimir-rock/issues)                                         |
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
| [Blackbox Exporter](https://snapcraft.io/prometheus-blackbox-exporter) | [Source](https://github.com/canonical/prometheus-blackbox-exporter-snap), [issues](https://github.com/canonical/prometheus-blackbox-exporter-snap/issues) |
| [Grafana Agent](https://snapcraft.io/grafana-agent)                     | [Source](https://github.com/canonical/grafana-agent-snap), [issues](https://github.com/canonical/grafana-agent-snap/issues)                     |
| [Node Exporter](https://snapcraft.io/node-exporter) | [Source](https://github.com/canonical/node-exporter-snap), [issues](https://github.com/canonical/node-exporter-snap/issues) |
| [OpenTelemetry Collector](https://snapcraft.io/opentelemetry-collector) | [Source](https://github.com/canonical/opentelemetry-collector-snap), [issues](https://github.com/canonical/opentelemetry-collector-snap/issues) |


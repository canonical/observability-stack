---
myst:
 html_meta:
  description: "Browse the complete reference for Canonical Observability Stack charms, rocks and snaps, including component roles, deployment-relevant details and registry locations."
---

# COS components

## COS charms

| Component                  | Substrate | Charmhub                                                 | Source Code                                                              | Bug Report                                                                      |
|--------------------------|-----------|----------------------------------------------------------|--------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| Catalogue                | K8s       | [Charmhub](https://charmhub.io/catalogue-k8s)            | [Source](https://github.com/canonical/catalogue-k8s-operator)            | [Issues](https://github.com/canonical/catalogue-k8s-operator/issues)            |
| Grafana                  | K8s       | [Charmhub](https://charmhub.io/grafana-k8s)              | [Source](https://github.com/canonical/grafana-k8s-operator)              | [Issues](https://github.com/canonical/grafana-k8s-operator/issues)              |
| Loki Coordinator         | K8s       | [Charmhub](https://charmhub.io/loki-coordinator-k8s)     | [Source](https://github.com/canonical/loki-coordinator-k8s-operator)     | [Issues](https://github.com/canonical/loki-coordinator-k8s-operator/issues)     |
| Loki Worker              | K8s       | [Charmhub](https://charmhub.io/loki-worker-k8s)          | [Source](https://github.com/canonical/loki-worker-k8s-operator)          | [Issues](https://github.com/canonical/loki-worker-k8s-operator/issues)          |
| Mimir Coordinator        | K8s       | [Charmhub](https://charmhub.io/mimir-coordinator-k8s)    | [Source](https://github.com/canonical/mimir-coordinator-k8s-operator)    | [Issues](https://github.com/canonical/mimir-coordinator-k8s-operator/issues)    |
| Mimir Worker             | K8s       | [Charmhub](https://charmhub.io/mimir-worker-k8s)         | [Source](https://github.com/canonical/mimir-worker-k8s-operator)         | [Issues](https://github.com/canonical/mimir-worker-k8s-operator/issues)         |
| S3 Integrator            | Any       | [Charmhub](https://charmhub.io/s3-integrator)            | [Source](https://github.com/canonical/s3-integrator)                     | [Issues](https://github.com/canonical/s3-integrator/issues)                     |
| Self-signed Certificates | Any       | [Charmhub](https://charmhub.io/self-signed-certificates) | [Source](https://github.com/canonical/self-signed-certificates-operator) | [Issues](https://github.com/canonical/self-signed-certificates-operator/issues) |
| Tempo Coordinator        | K8s       | [Charmhub](https://charmhub.io/tempo-coordinator-k8s)    | [Source](https://github.com/canonical/tempo-coordinator-k8s-operator)    | [Issues](https://github.com/canonical/tempo-coordinator-k8s-operator/issues)    |
| Tempo Worker             | K8s       | [Charmhub](https://charmhub.io/tempo-worker-k8s)         | [Source](https://github.com/canonical/tempo-worker-k8s-operator)         | [Issues](https://github.com/canonical/tempo-worker-k8s-operator/issues)         |
| Traefik                  | K8s       | [Charmhub](https://charmhub.io/traefik-k8s)              | [Source](https://github.com/canonical/traefik-k8s-operator)              | [Issues](https://github.com/canonical/traefik-k8s-operator/issues)              |

## COS Lite charms

| Component                  | Substrate | Charmhub                                                 | Source Code                                                              | Bug Report                                                                      |
|--------------------------|-----------|----------------------------------------------------------|--------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| Alertmanager             | K8s       | [Charmhub](https://charmhub.io/alertmanager-k8s)         | [Source](https://github.com/canonical/alertmanager-k8s-operator)         | [Issues](https://github.com/canonical/alertmanager-k8s-operator/issues)         |
| Catalogue                | K8s       | [Charmhub](https://charmhub.io/catalogue-k8s)            | [Source](https://github.com/canonical/catalogue-k8s-operator)            | [Issues](https://github.com/canonical/catalogue-k8s-operator/issues)            |
| Grafana                  | K8s       | [Charmhub](https://charmhub.io/grafana-k8s)              | [Source](https://github.com/canonical/grafana-k8s-operator)              | [Issues](https://github.com/canonical/grafana-k8s-operator/issues)              |
| Loki                     | K8s       | [Charmhub](https://charmhub.io/loki-k8s)                 | [Source](https://github.com/canonical/loki-k8s-operator)                 | [Issues](https://github.com/canonical/loki-k8s-operator/issues)                 |
| Prometheus               | K8s       | [Charmhub](https://charmhub.io/prometheus-k8s)           | [Source](https://github.com/canonical/prometheus-k8s-operator)           | [Issues](https://github.com/canonical/prometheus-k8s-operator/issues)           |
| Traefik                  | K8s       | [Charmhub](https://charmhub.io/traefik-k8s)              | [Source](https://github.com/canonical/traefik-k8s-operator)              | [Issues](https://github.com/canonical/traefik-k8s-operator/issues)              |
| Self-signed Certificates | Any       | [Charmhub](https://charmhub.io/self-signed-certificates) | [Source](https://github.com/canonical/self-signed-certificates-operator) | [Issues](https://github.com/canonical/self-signed-certificates-operator/issues) |

## Peripheral charms

| Component                  | Substrate | Charmhub                                                     | Source Code                                                                  | Bug Report                                                                          |
|--------------------------|-----------|--------------------------------------------------------------|------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| Blackbox Exporter        | K8s       | [Charmhub](https://charmhub.io/blackbox-exporter-k8s)        | [Source](https://github.com/canonical/blackbox-exporter-k8s-operator)        | [Issues](https://github.com/canonical/blackbox-exporter-k8s-operator/issues)        |
| Blackbox Exporter        | Machine       | [Charmhub](https://charmhub.io/blackbox-exporter)        | [Source](https://github.com/canonical/blackbox-exporter-operator)        | [Issues](https://github.com/canonical/blackbox-exporter-operator/issues)        |
| COS Configuration        | K8s       | [Charmhub](https://charmhub.io/cos-configuration-k8s)        | [Source](https://github.com/canonical/cos-configuration-k8s-operator)        | [Issues](https://github.com/canonical/cos-configuration-k8s-operator/issues)        |
| COS Proxy                | Machines  | [Charmhub](https://charmhub.io/cos-proxy)                    | [Source](https://github.com/canonical/cos-proxy-operator)                    | [Issues](https://github.com/canonical/cos-proxy-operator/issues)                    |
| Grafana Agent            | K8s       | [Charmhub](https://charmhub.io/grafana-agent-k8s)            | [Source](https://github.com/canonical/grafana-agent-k8s-operator)            | [Issues](https://github.com/canonical/grafana-agent-k8s-operator/issues)            |
| Grafana Agent            | Machines  | [Charmhub](https://charmhub.io/grafana-agent)                | [Source](https://github.com/canonical/grafana-agent-operator)                | [Issues](https://github.com/canonical/grafana-agent-operator/issues)                |
| Opentelemetry Collector         | K8s       | [Charmhub](https://charmhub.io/opentelemetry-collector-k8s)               | [Source](https://github.com/canonical/opentelemetry-collector-k8s-operator)            | [Issues](https://github.com/canonical/opentelemetry-collector-k8s-operator/issues)            |
| Opentelemetry Collector            | Machines  | [Charmhub](https://charmhub.io/opentelemetry-collector)               | [Source](https://github.com/canonical/grafana-agent-operator)                | [Issues](https://github.com/canonical/opentelemetry-collector-operator/issues)  
| Karma                    | K8s       | [Charmhub](https://charmhub.io/karma-k8s)                    | [Source](https://github.com/canonical/karma-k8s-operator)                    | [Issues](https://github.com/canonical/karma-k8s-operator/issues)                    |
| Karma Alertmanager Proxy | K8s       | [Charmhub](https://charmhub.io/karma-alertmanager-proxy-k8s) | [Source](https://github.com/canonical/karma-alertmanager-proxy-k8s-operator) | [Issues](https://github.com/canonical/karma-alertmanager-proxy-k8s-operator/issues) |
| Prometheus Scrape Config | Any       | [Charmhub](https://charmhub.io/prometheus-scrape-config-k8s) | [Source](https://github.com/canonical/prometheus-scrape-config-k8s-operator)     | [Issues](https://github.com/canonical/prometheus-scrape-config-k8s-operator/issues)     |
| Prometheus Scrape Target | Any       | [Charmhub](https://charmhub.io/prometheus-scrape-target-k8s) | [Source](https://github.com/canonical/prometheus-scrape-target-k8s-operator)     | [Issues](https://github.com/canonical/prometheus-scrape-target-k8s-operator/issues)     |
| Script Exporter          | K8s       | [Charmhub](https://charmhub.io/script-exporter)              | [Source](https://github.com/canonical/script-exporter-operator)              | [Issues](https://github.com/canonical/script-exporter-operator/issues)              |
| SNMP Exporter            | Machines  | -                | [Source](https://github.com/canonical/snmp-exporter-operator)                | [Issues](https://github.com/canonical/snmp-exporter-operator/issues)                |


## Rocks


| Image                              | Registry                                                                  | Source Code                                                           | Bug Report                                                                   |
|------------------------------------|---------------------------------------------------------------------------|-----------------------------------------------------------------------|------------------------------------------------------------------------------|
| `ubuntu/alertmanager`              | [Image](https://hub.docker.com/r/ubuntu/alertmanager)                     | [Source](https://github.com/canonical/alertmanager-rock)              | [Issues](https://github.com/canonical/alertmanager-rock/issues)              |
| `ubuntu/blackbox-exporter`         | [Image](https://hub.docker.com/r/ubuntu/blackbox-exporter)                | [Source](https://github.com/canonical/blackbox-exporter-rock)         | [Issues](https://github.com/canonical/blackbox-exporter-rock/issues)         |
| `ghcr.io/canonical/git-sync`       | --                                                                        | [Source](https://github.com/canonical/git-sync-rock)                  | [Issues](https://github.com/canonical/git-sync-rock/issues)                  |
| `ubuntu/grafana-agent`             | [Image](https://hub.docker.com/r/ubuntu/grafana-agent)                    | [Source](https://github.com/canonical/grafana-agent-rock)             | [Issues](https://github.com/canonical/grafana-agent-rock/issues)             |
| `ubuntu/grafana`                   | [Image](https://hub.docker.com/r/ubuntu/grafana)                          | [Source](https://github.com/canonical/grafana-rock)                   | [Issues](https://github.com/canonical/grafana-rock/issues)                   |
| `ubuntu/karma`                     | [Image](https://hub.docker.com/r/ubuntu/karma)                            | [Source](https://github.com/canonical/karma-rock)                     | [Issues](https://github.com/canonical/karma-rock/issues)                     |
| `ubuntu/loki`                      | [Image](https://hub.docker.com/r/ubuntu/loki)                             | [Source](https://github.com/canonical/loki-rock)                      | [Issues](https://github.com/canonical/loki-rock/issues)                      |
| `ubuntu/mimir`                     | [Image](https://hub.docker.com/r/ubuntu/mimir)                            | [Source](https://github.com/canonical/mimir-rock)                     | [Issues](https://github.com/canonical/mimir-rock/issues)                     |
| `ubuntu/nginx-prometheus-exporter` | [Image](https://hub.docker.com/r/ubuntu/nginx-prometheus-exporter)        | [Source](https://github.com/canonical/nginx-prometheus-exporter-rock) | [Issues](https://github.com/canonical/nginx-prometheus-exporter-rock/issues) |
| `ubuntu/node-exporter`             | [Image](https://hub.docker.com/r/ubuntu/node-exporter)                    | [Source](https://github.com/canonical/node-exporter-rock)             | [Issues](https://github.com/canonical/node-exporter-rock/issues)             |
| `ubuntu/opentelemetry-collector`   | [Image](https://hub.docker.com/r/ubuntu/opentelemetry-collector)          | [Source](https://github.com/canonical/opentelemetry-collector-rock)   | [Issues](https://github.com/canonical/opentelemetry-collector-rock/issues)   |
| `ubuntu/parca`                     | [Image](https://hub.docker.com/r/ubuntu/parca)                            | [Source](https://github.com/canonical/parca-rock)                     | [Issues](https://github.com/canonical/parca-rock/issues)                     |
| `ubuntu/prometheus-pushgateway`    | [Image](https://hub.docker.com/r/ubuntu/prometheus-pushgateway)           | [Source](https://github.com/canonical/prometheus-pushgateway-rock)    | [Issues](https://github.com/canonical/prometheus-pushgateway-rock/issues)    |
| `ghcr.io/canonical/s3proxy`        | [Image](https://github.com/canonical/s3proxy-rock/pkgs/container/s3proxy) | [Source](https://github.com/canonical/s3proxy-rock)                   | [Issues](https://github.com/canonical/s3proxy-rock/issues)                   |
| `ubuntu/tempo`                     | [Image](https://hub.docker.com/r/ubuntu/tempo)                            | [Source](https://github.com/canonical/tempo-rock)                     | [Issues](https://github.com/canonical/tempo-rock/issues)                     |
| `ubuntu/xk6`                       | [Image](https://hub.docker.com/r/ubuntu/xk6)                              | [Source](https://github.com/canonical/xk6-rock)                       | [Issues](https://github.com/canonical/xk6-rock/issues)                       |


## Snaps

| Image                   | Snapcraft Store                                       | Source Code                                                         | Bug Report                                                                 |
|-------------------------|-------------------------------------------------------|---------------------------------------------------------------------|----------------------------------------------------------------------------|
| Grafana Agent           | [Store](https://snapcraft.io/grafana-agent)           | [Source](https://github.com/canonical/grafana-agent-snap)           | [Issues](https://github.com/canonical/grafana-agent-snap/issues)           |
| OpenTelemetry Collector | [Store](https://snapcraft.io/opentelemetry-collector) | [Source](https://github.com/canonical/opentelemetry-collector-snap) | [Issues](https://github.com/canonical/opentelemetry-collector-snap/issues) |

---
myst:
  html_meta:
    description: "Use the example deployment dashboard to inspect the telemetry pipeline, collector health, backends, and high availability of a COS deployment."
---

# How to use the deployment dashboard

`examples/deployment-dashboard.json` is a Grafana dashboard template for investigating a full
COS deployment. It follows the telemetry pipeline from targets, to edge collectors, to the COS
collector, to the backends (Mimir, Loki, Tempo), and adds a high-availability check for the
COS applications.

It is a template rather than a ready-to-use dashboard, so set one variable after importing it,
then sync it into Grafana.

## Set the COS model

The High availability and Backends rows are scoped to the Juju model that hosts your COS
applications. Set the **COS model** variable at the top of the dashboard to that model.

Until you do, the panels scoped to it read **Set the COS model** rather than showing a
misleading empty graph. Nothing else needs configuring: the **Collector job** variable
defaults to `otelcol-internal`, which is what the collector charm uses.

## Sync the dashboard into Grafana

Point the [cos-configuration-k8s](https://charmhub.io/cos-configuration-k8s) charm at the
`examples` directory:

```shell
juju config cos-config grafana_dashboards_path=examples/
juju relate cos-config grafana-k8s
```

The charm then provisions the dashboard into Grafana on every sync. Because it is provisioned,
it is read-only in the Grafana UI: edit the JSON in the repository and let the charm sync it,
rather than editing the dashboard in Grafana.

To import it by hand instead, use the Grafana import dialog with the JSON file.

## Read the dashboard

- **High availability**: whether the COS applications that need more than one replica are
  scaled, which ones are not, and how many units are down.
- **Telemetry pipelines**: logs, metrics and traces, each as a row of Edge collectors, the COS
  collector, and the backend. Read each row left to right: a break shows as refusals or export
  failures at the hop where it happens.
- **Collectors**: the collectors' own health. Restarts, uptime, CPU and memory are ranked
  lists; the filter and exporter queue are trends.
- **Backends**: the Mimir, Loki and Tempo ingesters directly, as Active, In memory, and
  Flushed to S3.

## See also

- [Deployment topology best practices](../../reference/topology)
- [Sync alert rules and dashboards from a git repo](../integrate/sync-alert-rules-from-git-repo)

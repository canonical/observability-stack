---
myst:
  html_meta:
    description: "Use the example deployment dashboard to inspect the telemetry pipeline, collector health, backends, and high availability of a COS deployment."
---

# How to use the deployment dashboard

COS ships an example Grafana dashboard, `examples/deployment-dashboard.json`, for
investigating a full COS deployment. It follows telemetry from targets, to edge collectors,
to the COS collector, to the backends (Mimir, Loki, Tempo), and it checks that the COS
applications are scaled for high availability.

It is a template rather than a finished dashboard, so there is one variable to set after you
import it, and then you sync it into Grafana.

## Set the COS model

The High availability and Backends rows are scoped to the Juju model that hosts your COS
applications. Set the `COS model` variable at the top of the dashboard to that model, and
those rows fill in.

Until you do, their panels read "Set the COS model" instead of showing an empty graph, so it
is clear the dashboard is not yet scoped. Nothing else needs configuring: the `Collector
job` variable already defaults to `otelcol-internal`, the job the collector charm uses.

## Sync the dashboard into Grafana

Provisioning the dashboard with the cos-configuration-k8s charm keeps it in step with this
repository, so you never edit it in the Grafana UI.

Point the charm at the `examples` directory:

```shell
juju config cos-config grafana_dashboards_path=examples/
juju relate cos-config grafana-k8s
```

The charm then provisions the dashboard into Grafana on every sync. Because it is provisioned,
it is read-only in the Grafana UI: change the JSON in the repository and let the charm sync
it, rather than editing the dashboard by hand.

If you only want to look at it once, import the JSON file through the Grafana import dialog
instead.

## Read the dashboard

The dashboard is organized as rows, one per part of the stack.

- High availability: whether the COS applications that need more than one replica are
  scaled, which ones are not, and how many units are down.
- Telemetry pipelines: logs, metrics, and traces, each as a row of edge collectors, the
  COS collector, and the backend. Read a row left to right; a break shows as refusals or
  export failures at the hop where it happens.
- Collectors: the health of the collectors themselves. Restarts, uptime, CPU, and memory
  are ranked lists; the filter and exporter queue are trends.
- Backends: the Mimir, Loki, and Tempo ingesters, shown as Active, In memory, and Flushed
  to S3.

## See also

- [Deployment topology best practices](../../reference/topology)
- [Sync alert rules and dashboards from a git repo](../integrate/sync-alert-rules-from-git-repo)

---
myst:
  html_meta:
    description: "Learn how to define and set up Service Level Objectives using Sloth and cos-configuration-k8s in the Canonical Observability Stack."
---

# Set up SLOs with Sloth

This guide shows how to define Service Level Objectives (SLOs) and set them up
in COS using [Sloth](https://charmhub.io/sloth-k8s) and
[cos-configuration-k8s](https://charmhub.io/cos-configuration-k8s).

Sloth generates Prometheus recording and alerting rules from SLO specifications.
The generated rules work with both Prometheus (COS Lite) and Mimir (COS) as
the metrics backend. This guide uses Prometheus in examples, but the same
approach applies to Mimir deployments.

## Prerequisites

- A running COS or COS Lite deployment
- The `sloth-k8s` charm deployed and integrated with Prometheus or Mimir
- A git repository to store your SLO specifications

## Write an SLO specification

SLO specifications use the
[Sloth Prometheus/v1 format](https://pkg.go.dev/github.com/slok/sloth/pkg/prometheus/api/v1).
Create a YAML file with the following structure:

```{literalinclude} /how-to/integrate/alert-notifications.yaml
:language: yaml
```

## Translate SLI metrics to SLO queries

The SLI reference pages (such as
[Prometheus SLIs](/reference/cos-components/prometheus/sli))
list the metrics available for each component. To write the `error_query` and
`total_query` for your SLO:

1. Pick metrics from the SLI reference that represent the events you care about.
   In case the SLI reference doesn't exist for the charm / application you want to
   instrument, analyze the metrics and industry practices to find good SLI candidates.
2. Decide which events are "bad" (errors, failures, slow requests) and which form
   the total population.
3. Use `{{.window}}` as the range interval — Sloth replaces it with time
   windows when generating multi-window, multi-burn-rate alert rules.

For example, the SLO spec above is built from the **Alert notifications** SLI
group:

| SLI metric | Role in the SLO |
|---|---|
| `prometheus_notifications_dropped_total` | Bad event — dropped before sending |
| `prometheus_notifications_errors_total` | Bad event — error during sending |
| `prometheus_notifications_sent_total` | Total event — notification attempted |

The `error_query` sums both failure counters; the `total_query` sums
sent and dropped notifications to cover all attempts.

Two query patterns cover most SLOs:

**Availability — counter metrics**

Filter the total counter by an error label (e.g., HTTP 5xx status codes) to get
the error count:

```yaml
sli:
  events:
    error_query: |
      sum(rate(prometheus_http_requests_total{code=~"5.."}[{{.window}}]))
      or vector(0)
    total_query: |
      sum(rate(prometheus_http_requests_total[{{.window}}]))
```

**Latency — histogram metrics**

Subtract the bucket at your threshold from the total request count to get the
number of "slow" (bad) requests:

```yaml
sli:
  events:
    error_query: |
      sum(rate(prometheus_http_request_duration_seconds_count{handler="/api/v1/query"}[{{.window}}]))
      - sum(rate(prometheus_http_request_duration_seconds_bucket{handler="/api/v1/query",le="1"}[{{.window}}]))
    total_query: |
      sum(rate(prometheus_http_request_duration_seconds_count{handler="/api/v1/query"}[{{.window}}]))
      or vector(1)
```

The `or vector(1)` guard in the `total_query` prevents a divide-by-zero when no
requests have been observed (e.g., a quiet service).

### Adding Juju topology labels

In a COS deployment every metric is labelled with `juju_model`,
`juju_model_uuid`, and `juju_application`. Add these to your queries to target
a specific deployed application and avoid mixing data from multiple deployments:

```yaml
error_query: |
  sum(rate(prometheus_http_requests_total{
    juju_model="<model>",
    juju_model_uuid="<uuid>",
    juju_application="<app>",
    code=~"5.."
  }[{{.window}}])) or vector(0)
```

## Organise SLO files in a git repository

Create a directory structure in your git repository:

```text
your-repo/
└── slos/
    ├── prometheus-query-latency.yaml
    ├── prometheus-scrape-success.yaml
    └── grafana-dashboard-load.yaml
```

YAML files can contain multiple SLO specifications. Prefixing filenames with
the service name makes it easier to manage SLOs as your deployment grows.

## Deploy cos-configuration-k8s

Deploy the COS Configuration charm and point it at your git repository:

```bash
juju deploy cos-configuration-k8s cos-config
juju config cos-config \
    git_repo=https://github.com/your-org/your-slo-repo \
    git_branch=main \
    slos_path=slos
```

## Integrate with Sloth

Connect `cos-configuration-k8s` to `sloth-k8s`:

```bash
juju integrate cos-config:sloth sloth-k8s:sloth
```

The COS Configuration charm syncs your git repository periodically and forwards
SLO specifications to Sloth. Sloth then generates Prometheus recording and
alerting rules from each specification.

## Verify the SLOs are active

Check that Prometheus has received the generated rules:

```bash
juju ssh prometheus/0 curl -s http://localhost:9090/api/v1/rules | jq '.data.groups[].name' | grep sloth
```

You should see rule groups named with the pattern:
`<model>_<uuid>_<sloth-app>_sloth_slo_<type>_<service>_<slo-name>_alerts`

Each SLO generates three rule groups, one for each `<type>`: `sli_recordings`,
`meta_recordings`, and `alerts`.

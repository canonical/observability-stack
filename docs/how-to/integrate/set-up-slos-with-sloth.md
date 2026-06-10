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

```{literalinclude} /../slos/prometheus/notification-delivery.yaml
:language: yaml
```

## Organise SLO files in a git repository

Create a directory structure in your git repository:

```text
your-repo/
└── slos/
    ├── prometheus/
    │   ├── query-latency.yaml
    │   └── scrape-success.yaml
    └── grafana/
        └── dashboard-load.yaml
```

Each YAML file should contain one SLO specification. Organising by service
makes it easier to manage SLOs as your deployment grows.

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
`<model>_<hash>_sloth_slo_<service>_<slo-name>`

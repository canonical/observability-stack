---
myst:
 html_meta:
  description: "Understand versioning Terraform modules and tagging for strict reproducibility. This applies to product, component, and charm modules."
---

# Terraform module versioning

This document describes how the Observability Terraform modules are versioned and tagged.

## Module Types

There are three types of Terraform modules:

| Type | Description | Example |
|------|-------------|---------|
| **Charm** | Deploys a single charm | Alertmanager, Grafana |
| **Component** | Deploys multiple related charms | Mimir, Loki, Tempo |
| **Product** | Deploys a full observability stack | COS, COS Lite |

## Lifecycle of the Terraform modules

Terraform modules live alongside the charms or products they deploy, but their lifecycle depends on the branch:

| Branch | Purpose | Terraform Tags |
|--------|---------|----------------|
| `main` | Active development, releases to `dev/` track | None (untagged) |
| `track/{major}.{minor}` | Feature-frozen, releases to `{major}.{minor}/` track | `tf-{major}.{minor}.{patch}` |

For *charm* and *component* modules, the Terraform module in a track branch is designed to deploy *only* that specific charm track. For example, the module in `track/12.4` of the Grafana repository deploys the Grafana charm from track `12.4/`.

For *product* modules, we use an artificial track to identify a certain release. For example, COS 3.0 and its Terraform modules live in the `track/3.0` branch of the `canonical/observability-stack` repository.

### Track Guarantees

Track branches are **feature-frozen**: they only receive bug fixes and non-breaking improvements. New features and breaking changes go to a new track branch. This applies to everything: charms, components, products, and their Terraform modules.

This approach follows the release model adopted from charms, but **it deviates from semantic versioning in terms of guarantees**. Specifically. a new *minor* version could contain breaking changes, while a new *major* version might not. To summarize:
- Upgrading across patch versions (e.g., `12.4.0` to `12.4.5`) contains only non-breaking changes;
- Upgrading across minor or major versions (e.g., `12.4.x` → `12.6.x`) may include breaking changes; please check our documentation and release notes.

## Tagging Strategy

The Observability Terraform modules are tagged in GitHub following a consistent strategy:

| Module Type | Tag Format | Example |
|-------------|------------|---------|
| Charm (standalone repository) | `tf-{major}.{minor}.{patch}` | `tf-3.0.0` |
| Charm (monorepo) | `tf-{component}-{major}.{minor}.{patch}` | `tf-worker-3.0.0` |
| Component | `tf-{component}-{major}.{minor}.{patch}` | `tf-mimir-3.0.0` |
| Product | `tf-{product}-{major}.{minor}.{patch}` | `tf-cos-lite-3.0.0` |

### Pinning

Pinning our Terraform modules' `ref` via these tags **ensures strict reproducibility at the Terraform layer**. For production deployments, you should always pin modules to a tag.

## Input Variables

### Charm and Component Modules

These modules expose a `channel` variable (`track/risk`). The track portion is validated to match the module version:

```hcl
module "grafana" {
  source  = "git::https://github.com/canonical/grafana-k8s-operator//terraform?ref=tf-12.4.0"
  channel = "12.4/stable"  # Track must be 12.4
}
```

### Product Modules

Product modules (COS, COS Lite) expose only a `risk` variable, since the track is implicitly defined by the module version:

```hcl
module "cos" {
  source = "git::https://github.com/canonical/cos-lite//terraform?ref=tf-cos-3.0.0"
  risk   = "stable"
}
```

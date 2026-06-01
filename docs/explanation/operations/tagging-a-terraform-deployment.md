---
myst:
 html_meta:
  description: "Understand tagging Terraform modules for strict reproducibility. This applies to product, component, and charm modules."
---

# Tagging a Terraform module

To be able to achieve strict reproducibility (at the Terraform layer) when deploying COS, you can pin the module's ref to tags which exist in the [module's source](https://github.com/canonical/observability-stack/tags), that is, its GitHub repository. This feature extends to all Terraform modules maintained by the Observability team.

Terraform tags have a consistent format, following the convention:
- charm modules will be tagged as `tf-{major}.{minor}.{patch}` (e.g., `tf-3.0.0`)
- product modules, component modules, and charm modules in a monorepo will have an additional part to the prefix indicating what component the tag relates to (e.g., `tf-cos-3.0.0`, `tf-cos-lite-3.0.0`, `tf-coordinator-3.0.0`, `tf-worker-3.0.0`, `tf-mimir-3.0.0`, etc.)

To pin a specific tag, append `?ref=<tag>` to the module's `source` URL. For example:

```hcl
module "cos" {
  source = "git::https://github.com/canonical/observability-stack//terraform/cos?ref=tf-cos-3.0.0"
}
```

## Tagged modules are reproducible
Tagged product (and component) modules reference a set of tagged charm modules. This ensures that the Terraform layer for the entire product is reproducible and no side effects can occur.

## Modules on the main branch are not tagged
This branch is intended for "development" and may include features intended for the next track. On `main`, product (and component) modules will point at the `main` branch of its referenced modules.

## Tracks are feature-frozen

Terraform modules are versioned after the track they live in. For example, the Grafana Terraform module living in `track/12.4` should be versioned as `12.4.{patch}`. Any changes to the Terraform module in a track only bumps the `{patch}`.

Any breaking change in the Terraform module is featured in a new, separate track. The implication of this decision is that Terraform breaking changes are not accurately reflected in the semantic versioning: going from `12.4.0` to `12.6.0` could carry a breaking change both in Terraform, and in the charm. Similarly, going from `12.4.0` to `13.0.0` might not carry any breaking changes in Terraform. While this is not ideal, it matches the release model adopted from charms, and it's mitigated by documentation (in the form of release notes and migration guides) and by the next decision point.

## Terraform modules don't outlive a charm track
Terraform modules live with the charm, and a Terraform module in branch `track/12.4` of the Grafana repository should only be usable to deploy the Grafana charm from track `12.4`. This applies to all types of Terraform modules, not only charm: component modules live in the root of the monorepo and are versioned similarly (e.g., Loki Coordinator, Loki Worker, and the component module are all living on `track/3.7`); product modules have an artificial track which is used for documentation and to map to a number of charm tracks e.g., `track/3.0` for COS which points at specific tracks for Alertmanager, Catalogue, etc.

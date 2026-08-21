---
myst:
 html_meta:
   description: "Import an existing COS Lite Juju deployment into Terraform state using Atelier or manual terraform import."
---

# How to import an existing COS Lite deployment into Terraform

If you deployed COS Lite outside of Terraform and want to manage it with the
`terraform/cos-lite` module — or if you lost your `terraform.tfstate` and need
to recover it — this guide shows how to reconstruct Terraform state from a live
deployment.

```{warning}
Before importing, make sure the module version you plan to use is compatible with the
charms you have deployed. See the [release policy](/reference/release-policy) for
supported tracks.
```

## Prerequisites

- A running COS Lite deployment on a Juju `>= 3.6` controller.
- [Atelier](https://github.com/MichaelThamm/atelier) `>= 0.4.5` (for the automated method)
- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.14` with the
  [Juju Terraform provider](https://registry.terraform.io/providers/juju/juju) `>= 1.4.0`.

## Import with Atelier

[Atelier](https://github.com/MichaelThamm/atelier) automates the import by cloning the
upstream module, discovering live resources via `terraform query`, matching them to the
module's resource addresses, and running `terraform import` for each match.

### 1. Set up a wrapper directory

Create an empty directory and run `atelier import`:

```bash
mkdir cos-lite-import && cd cos-lite-import

atelier import juju \
  --source https://github.com/canonical/observability-stack.git \
  --module terraform/cos-lite \
  --ref track/2
```

COS Lite gives every variable a default, so no `--var` flags are needed.
Atelier picks up the model UUID from the live deployment (see
"How model UUID is resolved").

| Flag | Purpose |
|------|---------|
| `--source` | Upstream repository that contains the module |
| `--module` | Path to the Terraform module inside the repository |
| `--ref` | Git ref (branch or tag) matching your deployment track |
| `--query-var` | Variables the Juju provider needs to query live resources |
| `--var` | Module input variables the module requires |
| `--preset` | Named variable sets from an `atelier.local.yaml` file |
| `--dry-run` | Preview what would be imported without touching state |

```{note}
`--query-var model_uuid` is consumed by `terraform query` and is separate from
module input variables. You only need to pass it when your model UUID is not
automatically discoverable from live resources (e.g. a model with only offers).
```

#### How model UUID is resolved

Atelier resolves the model UUID in this order:

1. **Live resource identities** — the most frequent UUID prefix among all
   discovered objects is used.
2. **`--query-var model_uuid`** — the value supplied to the query engine.
3. **`--var model_uuid`** — a module input variable.

For COS Lite, which uses a `model = { uuid = ... }` object variable, the UUID
is injected into the wrapper automatically.

### 1a. Check coverage first (optional)

Use `--dry-run` to preview what would be imported without touching Terraform
state:

```bash
atelier import juju \
  --source https://github.com/canonical/observability-stack.git \
  --module terraform/cos-lite \
  --ref track/2 \
  --dry-run
```

The number to watch is **to add** — resources the module would create rather
than import. A non-zero count here means your variables do not match the
live deployment. An `imports.tf` artifact is written for review; Atelier does
**not** apply it.

### 2. Review the import results

Atelier prints a summary of what was matched and imported:

```
Matched 26 resource(s):
  module.cos_lite.module.alertmanager.juju_application.alertmanager  (import ID: eddaeb90-…:alertmanager)
  module.cos_lite.juju_integration.alertmanager_grafana_dashboards   (import ID: eddaeb90-…:alertmanager:grafana-dashboard:grafana:grafana-dashboard)
  …

Imported 26 resource(s) into state:
  ✓ module.cos_lite.module.alertmanager.juju_application.alertmanager
  ✓ module.cos_lite.module.catalogue.juju_application.catalogue
  …
```

Resources that were already in state are skipped. A second run over a
finished import reports `Nothing to import: all N matched resource(s) are
already in state.` and changes nothing.

Some module resources may remain unmatched. These typically fall into two
categories:

- **TLS resources** (`internal_certificates`, `ssc.*`) — created only when
  `var.internal_tls` is `true` (the default). If the original bundle had no
  self-signed-certificates application or TLS integrations, these are correctly
  unmatched and will be created on first apply.
- **Juju offers** — the Juju provider's query engine may not be able to
  enumerate offers on all controller versions. Import these manually (see
  Method 2).

Unmatched live resources (e.g. implicit peer relations) are left alone.

### 3. Plan

Open the wrapper with Atelier or run `terraform plan` directly:

```bash
terraform plan
```

The plan should show a small delta:

```
Plan: 3 to add, 2 to change, 0 to destroy.
```

- **Resources to add** are typically `terraform_data` replace-triggers and
  resources that had no live match (e.g. TLS components not present in the
  original deployment).
- **Resources to change** are attribute drift between the imported state and
  the module's current defaults — storage directives, resources, and similar
  optional fields that differ between the bundle's deployment and the
  module's opinionated defaults. These are safe to apply.

If the plan shows `0 to destroy`, the import is complete. Run `terraform apply`
to converge.

## Import manually (without Atelier)

To import without Atelier, use standard Terraform commands. This method
requires you to look up the model UUID yourself.

```bash
juju models --format json | jq -r '.models[] | select(.["short-name"] == "demo") | .["model-uuid"]'
eddaeb90-3115-4832-8bc4-ad4167df94dc
```

### 1. Prepare the Terraform root

Create a directory and write `main.tf`:

```hcl
terraform {
  required_version = ">= 1.14"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.4.0"
    }
  }
}

provider "juju" {}

module "cos_lite" {
  source = "git::https://github.com/canonical/observability-stack.git//terraform/cos-lite?ref=track/2"

  model_uuid = "eddaeb90-3115-4832-8bc4-ad4167df94dc"
}
```

Then initialize:

```bash
terraform init
```

```{note}
Use the `?ref=track/2` query parameter in the source URL to pin the module to
the track your deployment is on. See the [release policy](/reference/release-policy)
for available tracks.
```

### 2. Discover live resources with `terraform query`

The `terraform query` command (available in Terraform `>= 1.14`) enumerates
live objects from the provider. Create a query file covering the resource
types you need to import:

```text
# atelier-import.tfquery.hcl
list "juju_application" "juju_application" {
  provider        = juju
  include_resource = true
  config {
    model_uuid = "eddaeb90-3115-4832-8bc4-ad4167df94dc"
  }
}

list "juju_integration" "juju_integration" {
  provider        = juju
  include_resource = true
  config {
    model_uuid = "eddaeb90-3115-4832-8bc4-ad4167df94dc"
  }
}

list "juju_offer" "juju_offer" {
  provider        = juju
  include_resource = true
  config {
    model_uuid = "eddaeb90-3115-4832-8bc4-ad4167df94dc"
  }
}
```

Run the query:

```bash
terraform query -json > live-resources.json
```

This produces a JSON stream with one `list_resource_found` event per live
object. Each event carries:
- `resource_type` — e.g. `juju_application`
- `display_name` — the application name, e.g. `alertmanager`
- `identity` — provider-specific identity, e.g. `{"id": "eddaeb90-…:alertmanager"}`
- `resource_object` — full attribute map

### 3. Map module addresses to live objects

Run `terraform plan` to see the resource addresses the module declares:

```bash
terraform plan
```

From the plan output, build a list of module addresses and their corresponding
import IDs. For `juju_application`, the import ID format is
`<model_uuid>:<application_name>`:

| Module address | Import ID |
|---|---|
| `module.cos_lite.module.alertmanager.juju_application.alertmanager` | `eddaeb90-…:alertmanager` |
| `module.cos_lite.module.catalogue.juju_application.catalogue` | `eddaeb90-…:catalogue` |
| `module.cos_lite.module.grafana.juju_application.grafana` | `eddaeb90-…:grafana` |
| `module.cos_lite.module.loki.juju_application.loki` | `eddaeb90-…:loki` |
| `module.cos_lite.module.prometheus.juju_application.prometheus` | `eddaeb90-…:prometheus` |
| `module.cos_lite.module.ssc[0].juju_application.self-signed-certificates` | `eddaeb90-…:ca` |
| `module.cos_lite.module.traefik.juju_application.traefik` | `eddaeb90-…:traefik` |

For `juju_integration`, the import ID is the full identity `"id"` string from
the query output, e.g.
`eddaeb90-…:alertmanager:alerting:loki:alertmanager`.

Match each live object's identity to the module address by comparing
application names and endpoint pairs. The Juju provider list resource returns
identity objects with an `"id"` field in the format:

- `juju_application`: `<model_uuid>:<app_name>`
- `juju_integration`: `<model_uuid>:<provider_app>:<provider_endpoint>:<requirer_app>:<requirer_endpoint>`
- `juju_offer`: `<offer_url>` (e.g. `admin/demo.alertmanager-karma-dashboard`)

### 4. Write an `imports.tf` file

With the mappings built, write an `imports.tf` file with `import {}` blocks
(Terraform `>= 1.5`):

```hcl
# imports.tf

import {
  to = module.cos_lite.module.alertmanager.juju_application.alertmanager
  id = "eddaeb90-…:alertmanager"
}

import {
  to = module.cos_lite.module.catalogue.juju_application.catalogue
  id = "eddaeb90-…:catalogue"
}

import {
  to = module.cos_lite.module.grafana.juju_application.grafana
  id = "eddaeb90-…:grafana"
}

import {
  to = module.cos_lite.module.loki.juju_application.loki
  id = "eddaeb90-…:loki"
}

import {
  to = module.cos_lite.module.prometheus.juju_application.prometheus
  id = "eddaeb90-…:prometheus"
}

import {
  to = module.cos_lite.module.ssc[0].juju_application.self-signed-certificates
  id = "eddaeb90-…:ca"
}

import {
  to = module.cos_lite.module.traefik.juju_application.traefik
  id = "eddaeb90-…:traefik"
}

import {
  to = module.cos_lite.juju_integration.alertmanager_certificates[0]
  id = "eddaeb90-…:ca:certificates:alertmanager:certificates"
}

import {
  to = module.cos_lite.juju_integration.alertmanager_grafana_dashboards
  id = "eddaeb90-…:alertmanager:grafana-dashboard:grafana:grafana-dashboard"
}

import {
  to = module.cos_lite.juju_integration.alertmanager_ingress
  id = "eddaeb90-…:traefik:ingress:alertmanager:ingress"
}

import {
  to = module.cos_lite.juju_integration.alertmanager_loki
  id = "eddaeb90-…:alertmanager:alerting:loki:alertmanager"
}

import {
  to = module.cos_lite.juju_integration.alertmanager_prometheus
  id = "eddaeb90-…:alertmanager:alerting:prometheus:alertmanager"
}

import {
  to = module.cos_lite.juju_integration.alertmanager_self_monitoring_prometheus
  id = "eddaeb90-…:alertmanager:self-metrics-endpoint:prometheus:metrics-endpoint"
}

import {
  to = module.cos_lite.juju_integration.catalogue_alertmanager
  id = "eddaeb90-…:catalogue:catalogue:alertmanager:catalogue"
}

import {
  to = module.cos_lite.juju_integration.catalogue_certificates[0]
  id = "eddaeb90-…:ca:certificates:catalogue:certificates"
}

import {
  to = module.cos_lite.juju_integration.catalogue_grafana
  id = "eddaeb90-…:catalogue:catalogue:grafana:catalogue"
}

import {
  to = module.cos_lite.juju_integration.catalogue_ingress
  id = "eddaeb90-…:traefik:ingress:catalogue:ingress"
}

import {
  to = module.cos_lite.juju_integration.catalogue_prometheus
  id = "eddaeb90-…:catalogue:catalogue:prometheus:catalogue"
}

import {
  to = module.cos_lite.juju_integration.grafana_certificates[0]
  id = "eddaeb90-…:ca:certificates:grafana:certificates"
}

import {
  to = module.cos_lite.juju_integration.grafana_ingress
  id = "eddaeb90-…:traefik:traefik-route:grafana:ingress"
}

import {
  to = module.cos_lite.juju_integration.grafana_self_monitoring_prometheus
  id = "eddaeb90-…:grafana:metrics-endpoint:prometheus:metrics-endpoint"
}

import {
  to = module.cos_lite.juju_integration.grafana_source_alertmanager
  id = "eddaeb90-…:alertmanager:grafana-source:grafana:grafana-source"
}

import {
  to = module.cos_lite.juju_integration.loki_certificates[0]
  id = "eddaeb90-…:ca:certificates:loki:certificates"
}

import {
  to = module.cos_lite.juju_integration.loki_grafana_dashboards_provider
  id = "eddaeb90-…:loki:grafana-dashboard:grafana:grafana-dashboard"
}

import {
  to = module.cos_lite.juju_integration.loki_grafana_source
  id = "eddaeb90-…:loki:grafana-source:grafana:grafana-source"
}

import {
  to = module.cos_lite.juju_integration.loki_ingress
  id = "eddaeb90-…:traefik:ingress-per-unit:loki:ingress"
}

import {
  to = module.cos_lite.juju_integration.loki_self_monitoring_prometheus
  id = "eddaeb90-…:loki:metrics-endpoint:prometheus:metrics-endpoint"
}

import {
  to = module.cos_lite.juju_integration.prometheus_certificates[0]
  id = "eddaeb90-…:ca:certificates:prometheus:certificates"
}

import {
  to = module.cos_lite.juju_integration.prometheus_grafana_dashboards_provider
  id = "eddaeb90-…:prometheus:grafana-dashboard:grafana:grafana-dashboard"
}

import {
  to = module.cos_lite.juju_integration.prometheus_grafana_source
  id = "eddaeb90-…:prometheus:grafana-source:grafana:grafana-source"
}

import {
  to = module.cos_lite.juju_integration.prometheus_ingress
  id = "eddaeb90-…:traefik:ingress-per-unit:prometheus:ingress"
}

import {
  to = module.cos_lite.juju_integration.traefik_receive_ca_certificate[0]
  id = "eddaeb90-…:ca:send-ca-cert:traefik:receive-ca-cert"
}

import {
  to = module.cos_lite.juju_integration.traefik_self_monitoring_prometheus
  id = "eddaeb90-…:traefik:metrics-endpoint:prometheus:metrics-endpoint"
}

# Optional: Offers (if your controller supports querying them)
import {
  to = module.cos_lite.juju_offer.alertmanager_karma_dashboard
  id = "admin/demo.alertmanager-karma-dashboard"
}

import {
  to = module.cos_lite.juju_offer.grafana_dashboards
  id = "admin/demo.grafana-dashboards"
}

import {
  to = module.cos_lite.juju_offer.loki_logging
  id = "admin/demo.loki-logging"
}

import {
  to = module.cos_lite.juju_offer.prometheus_metrics_endpoint
  id = "admin/demo.prometheus-metrics-endpoint"
}

import {
  to = module.cos_lite.juju_offer.prometheus_receive_remote_write
  id = "admin/demo.prometheus-receive-remote-write"
}

import {
  to = module.cos_lite.module.ssc[0].juju_offer.certificates
  id = "admin/demo.certificates"
}

import {
  to = module.cos_lite.module.ssc[0].juju_offer.send_ca_cert
  id = "admin/demo.send-ca-cert"
}
```

```{note}
The offer URL in the import ID depends on your Juju controller's model name.
Replace `admin/demo.` with `admin/<your-model-name>.` as needed. You can find
offer URLs by running `juju status` and looking at the `Offer` section.
```

```{warning}
`terraform apply` with `import {}` blocks present executes the whole plan,
not just the imports. If this file does not cover every resource the module
declares, apply will **create** the ones it misses — duplicating live
infrastructure. Check that `terraform plan` reports `0 to add` before
applying.
```

### 5. Plan and apply

Run `terraform plan`:

```bash
terraform plan
```

The plan should show a small delta:

```
Plan: 3 to add, 2 to change, 0 to destroy.
```

- **Resources to add** are typically `terraform_data` replace-triggers and
  resources that had no live match (e.g. TLS components not present in the
  original deployment).
- **Resources to change** are attribute drift between the imported state and
  the module's current defaults — storage directives, resources, and similar
  optional fields that differ between the bundle's deployment and the
  module's opinionated defaults. These are safe to apply.

If the plan shows `0 to destroy`, run `terraform apply` to import and
converge:

```bash
terraform apply
```

After applying, remove `imports.tf`. Leaving it in place would re-import on
every plan:

```bash
rm imports.tf
```

## Safety properties

- **Importing writes state only.** `terraform import` and `import {}` blocks
  do not create or destroy infrastructure. A bad import produces a bad state
  file, not a damaged deployment. That said, `terraform apply` with `import {}`
  blocks present runs the full plan — not just the imports — so check
  `terraform plan` reports `0 to add` before applying.
- **Re-running is safe.** Resources already in state are skipped. The loop is:
  run, read the report, fix variables, run again.
- **Model mismatch is refused** (Atelier only). If the wrapper targets a
  different model than the live resources, Atelier aborts. Proceeding would
  destroy every imported resource on the next apply.
- **Check the plan before applying.** `juju_application` resources must not
  show `replace` or `create`. A clean import shows only attribute drift and
  Terraform-internal resources with no live counterpart.

## Next steps

With state imported, you can manage the deployment with normal Terraform
operations.

```{seealso}
- [Cross-track upgrade](/how-to/deploy-and-manage/upgrade/)
- [Release notes](../../release-notes.md)
- [Juju Terraform provider](https://registry.terraform.io/providers/juju/juju)
```

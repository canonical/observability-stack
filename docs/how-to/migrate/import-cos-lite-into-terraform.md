---
myst:
 html_meta:
   description: "Import an existing COS Lite Juju deployment into Terraform state using Atelier or manual terraform import."
---

# How to import an existing COS Lite deployment into Terraform

If you deployed COS Lite via a Juju bundle (or any means other than Terraform) and now want to manage it with the `terraform/cos-lite` module, or if you lost your `terraform.tfstate` file and need to recover it, this guide shows two ways to reconstruct Terraform state from a live deployment.

```{warning}
Before importing, make sure the module version you plan to use is compatible with the
charms you have deployed. See the [release policy](/reference/release-policy) for
supported tracks.
```

## Prerequisites

- A running COS Lite deployment on a Juju `>= 3.6` controller.
- [Atelier](https://github.com/MichaelThamm/atelier) (for the automated method)
- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.5` with the
  [Juju Terraform provider](https://registry.terraform.io/providers/juju/juju) `>= 1.4.0`.
- The model UUID of your COS Lite deployment.

---

## Get the model UUID

```bash
juju models --format json | jq -r '.models[] | select(.["short-name"] == "demo") | .["model-uuid"]'
eddaeb90-3115-4832-8bc4-ad4167df94dc
```

You will need this value in both methods below.

---

## Method 1: Import with Atelier

[Atelier](https://github.com/MichaelThamm/atelier) automates the import by cloning the
upstream module, discovering live resources via `terraform query`, matching them to the
module's resource addresses, and running `terraform import` for each match.

### 1. Set up a wrapper directory

Create an empty directory and run `atelier import`, passing the required module
variables with `--var` flags:

```bash
mkdir cos-lite-import && cd cos-lite-import

atelier import juju \
  --source https://github.com/canonical/observability-stack.git \
  --module terraform/cos-lite \
  --ref track/2 \
  --query-var model_uuid=eddaeb90-3115-4832-8bc4-ad4167df94dc \
  --var model_uuid=eddaeb90-3115-4832-8bc4-ad4167df94dc
```

What the flags do:

| Flag | Purpose |
|------|---------|
| `--source` | Upstream repository that contains the module |
| `--module` | Path to the Terraform module inside the repository |
| `--ref` | Git ref (branch or tag) matching your deployment track |
| `--query-var` | Variables the Juju provider needs to query live resources |
| `--var` | Module input variables the module requires |

```{note}
`--query-var model_uuid` is consumed by `terraform query` and is separate from
`--var model_uuid`, which is a module input variable that tells the module
which existing model to manage. Both are required.
```

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

Some module resources may remain unmatched. These typically fall into two categories:

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

---

## Method 2: Import manually (without Atelier)

If you prefer not to use Atelier, you can import resources step by step with
standard Terraform commands.

### 1. Prepare the Terraform root

Create a directory and write `main.tf`:

```hcl
terraform {
  required_version = ">= 1.5"
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

Then initialise:

```bash
terraform init
```

```{note}
Use the `?ref=track/2` query parameter in the source URL to pin the module to
the track your deployment is on. See the [release policy](/reference/release-policy)
for available tracks.
```

### 2. Discover live resources with `terraform query`

The `terraform query` command (available in Terraform `>= 1.10`) enumerates
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

```{note}
Atelier generates a larger query file that also covers `juju_machine`,
`juju_model`, `juju_secret`, and `juju_storage_pool` — all list resource types
the provider offers. Only the three types shown above are needed for a COS
Lite import; the extra types are harmless and are included by Atelier for
completeness.
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

### 4. Import resources

With the mappings built, import each resource:

```bash
# Applications
terraform import 'module.cos_lite.module.alertmanager.juju_application.alertmanager' 'eddaeb90-…:alertmanager'
terraform import 'module.cos_lite.module.catalogue.juju_application.catalogue'        'eddaeb90-…:catalogue'
terraform import 'module.cos_lite.module.grafana.juju_application.grafana'             'eddaeb90-…:grafana'
terraform import 'module.cos_lite.module.loki.juju_application.loki'                   'eddaeb90-…:loki'
terraform import 'module.cos_lite.module.prometheus.juju_application.prometheus'       'eddaeb90-…:prometheus'
terraform import 'module.cos_lite.module.ssc[0].juju_application.self-signed-certificates' 'eddaeb90-…:ca'
terraform import 'module.cos_lite.module.traefik.juju_application.traefik'             'eddaeb90-…:traefik'

# Integrations
terraform import 'module.cos_lite.juju_integration.alertmanager_certificates[0]'              'eddaeb90-…:ca:certificates:alertmanager:certificates'
terraform import 'module.cos_lite.juju_integration.alertmanager_grafana_dashboards'           'eddaeb90-…:alertmanager:grafana-dashboard:grafana:grafana-dashboard'
terraform import 'module.cos_lite.juju_integration.alertmanager_ingress'                      'eddaeb90-…:traefik:ingress:alertmanager:ingress'
terraform import 'module.cos_lite.juju_integration.alertmanager_loki'                         'eddaeb90-…:alertmanager:alerting:loki:alertmanager'
terraform import 'module.cos_lite.juju_integration.alertmanager_prometheus'                   'eddaeb90-…:alertmanager:alerting:prometheus:alertmanager'
terraform import 'module.cos_lite.juju_integration.alertmanager_self_monitoring_prometheus'    'eddaeb90-…:alertmanager:self-metrics-endpoint:prometheus:metrics-endpoint'
terraform import 'module.cos_lite.juju_integration.catalogue_alertmanager'                    'eddaeb90-…:catalogue:catalogue:alertmanager:catalogue'
terraform import 'module.cos_lite.juju_integration.catalogue_certificates[0]'                 'eddaeb90-…:ca:certificates:catalogue:certificates'
terraform import 'module.cos_lite.juju_integration.catalogue_grafana'                         'eddaeb90-…:catalogue:catalogue:grafana:catalogue'
terraform import 'module.cos_lite.juju_integration.catalogue_ingress'                         'eddaeb90-…:traefik:ingress:catalogue:ingress'
terraform import 'module.cos_lite.juju_integration.catalogue_prometheus'                      'eddaeb90-…:catalogue:catalogue:prometheus:catalogue'
terraform import 'module.cos_lite.juju_integration.grafana_certificates[0]'                   'eddaeb90-…:ca:certificates:grafana:certificates'
terraform import 'module.cos_lite.juju_integration.grafana_ingress'                           'eddaeb90-…:traefik:traefik-route:grafana:ingress'
terraform import 'module.cos_lite.juju_integration.grafana_self_monitoring_prometheus'        'eddaeb90-…:grafana:metrics-endpoint:prometheus:metrics-endpoint'
terraform import 'module.cos_lite.juju_integration.grafana_source_alertmanager'               'eddaeb90-…:alertmanager:grafana-source:grafana:grafana-source'
terraform import 'module.cos_lite.juju_integration.loki_certificates[0]'                      'eddaeb90-…:ca:certificates:loki:certificates'
terraform import 'module.cos_lite.juju_integration.loki_grafana_dashboards_provider'          'eddaeb90-…:loki:grafana-dashboard:grafana:grafana-dashboard'
terraform import 'module.cos_lite.juju_integration.loki_grafana_source'                       'eddaeb90-…:loki:grafana-source:grafana:grafana-source'
terraform import 'module.cos_lite.juju_integration.loki_ingress'                              'eddaeb90-…:traefik:ingress-per-unit:loki:ingress'
terraform import 'module.cos_lite.juju_integration.loki_self_monitoring_prometheus'           'eddaeb90-…:loki:metrics-endpoint:prometheus:metrics-endpoint'
terraform import 'module.cos_lite.juju_integration.prometheus_certificates[0]'                'eddaeb90-…:ca:certificates:prometheus:certificates'
terraform import 'module.cos_lite.juju_integration.prometheus_grafana_dashboards_provider'    'eddaeb90-…:prometheus:grafana-dashboard:grafana:grafana-dashboard'
terraform import 'module.cos_lite.juju_integration.prometheus_grafana_source'                 'eddaeb90-…:prometheus:grafana-source:grafana:grafana-source'
terraform import 'module.cos_lite.juju_integration.prometheus_ingress'                        'eddaeb90-…:traefik:ingress-per-unit:prometheus:ingress'
terraform import 'module.cos_lite.juju_integration.traefik_receive_ca_certificate[0]'         'eddaeb90-…:ca:send-ca-cert:traefik:receive-ca-cert'
terraform import 'module.cos_lite.juju_integration.traefik_self_monitoring_prometheus'         'eddaeb90-…:traefik:metrics-endpoint:prometheus:metrics-endpoint'

# Optional: Offers (if your controller supports querying them)
terraform import 'module.cos_lite.juju_offer.alertmanager_karma_dashboard'     'admin/demo.alertmanager-karma-dashboard'
terraform import 'module.cos_lite.juju_offer.grafana_dashboards'               'admin/demo.grafana-dashboards'
terraform import 'module.cos_lite.juju_offer.loki_logging'                     'admin/demo.loki-logging'
terraform import 'module.cos_lite.juju_offer.prometheus_metrics_endpoint'      'admin/demo.prometheus-metrics-endpoint'
terraform import 'module.cos_lite.juju_offer.prometheus_receive_remote_write'  'admin/demo.prometheus-receive-remote-write'
terraform import 'module.cos_lite.module.ssc[0].juju_offer.certificates'       'admin/demo.certificates'
terraform import 'module.cos_lite.module.ssc[0].juju_offer.send_ca_cert'       'admin/demo.send-ca-cert'
```

```{note}
The offer URL in the import ID depends on your Juju controller's model name.
Replace `admin/demo.` with `admin/<your-model-name>.` as needed. You can find
offer URLs by running `juju status` and looking at the `Offer` section.
```

### 5. Post-import state normalisation

After importing, Terraform may report diffs for optional attributes that the
Juju provider stores as `null` but the module sets to `{}`:

```bash
terraform plan
```

Apply once to converge these attribute defaults:

```bash
terraform apply
```

### 6. Verify the plan

```bash
terraform plan
```

You should see a minimal delta:

```
Plan: 3 to add, 2 to change, 0 to destroy.
```

---

## Next steps

With state imported, you can manage the deployment with normal Terraform
operations.

```{seealso}
- [Cross-track upgrade](/how-to/deploy-and-manage/upgrade/)
- [Release notes](../../release-notes.md)
- [Juju Terraform provider](https://registry.terraform.io/providers/juju/juju)
```

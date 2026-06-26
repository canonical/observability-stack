---
myst:
 html_meta:
   description: "Configure the Grafana database within the Canonical Observability Stack (COS)."
---

# How to configure the Grafana database

Grafana stores its state (dashboards, users, and settings) in a database. In COS you can either:

- Use the default per-unit Juju storage (single Grafana unit only), or
- Integrate Grafana with an external PostgreSQL database, which is required to scale Grafana to more than one unit for high availability.

Which path is used is controlled by the `postgresql_offer_url` and `grafana.units` inputs of the Terraform module:

- When `postgresql_offer_url` is set, Grafana is integrated with the external PostgreSQL service over the `postgresql_client` interface, at any scale.
- When `postgresql_offer_url` is `null` (the default), Grafana uses the default Juju storage. In this case Grafana **must** run as a single unit.

```{important}
Grafana defaults to 3 units in COS and 1 unit in COS Lite.

Running more than one Grafana unit requires a shared external database. Therefore, whenever `grafana.units` is greater than 1, you must also set `postgresql_offer_url`. If you don't, applying the module fails validation on a Terraform plan.
```

## Configure an external database

To back Grafana with an external PostgreSQL database, supply the `postgresql_offer_url` input with the Juju offer URL of a PostgreSQL service that provides the `postgresql_client` integration (for example, `admin/postgresql.database`). Set `grafana.units` to the desired number of Grafana units for high availability.

```{literalinclude} /how-to/deploy-and-manage/cos-grafana-database.tf
```

The `postgresql_offer_url` input determines whether Grafana is integrated with the external database. When it is set, COS creates a cross-model integration between Grafana and the PostgreSQL service, regardless of the Grafana unit count. You can therefore use an external database even when running a single Grafana unit.

Ensure that you have provided any required variables (update the `... other inputs ...` placeholder) for the respective COS module before applying the configuration, by running `terraform apply`.

## Configure Juju storage

If you do not supply `postgresql_offer_url`, Grafana falls back to SQLite. This is only supported with a single Grafana unit, so set `grafana.units` to `1`:

```hcl
module "cos" {
  grafana = { units = 1 }
  postgresql_offer_url = null
}
```

For details on sizing and customizing the underlying storage, see [How to customize storage options](/how-to/configure-and-tune/customize-storage-options.md) and the [Storage best practices](/reference/storage.md) reference.

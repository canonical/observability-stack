module "cos" {
  # Use the right source value depending on whether you are using cos or cos-lite
  source = "git::https://github.com/canonical/observability-stack//terraform/cos?ref=main"

  # ... other inputs ...

  # Number of Grafana units. Scaling above 1 requires an external database,
  # so 'postgresql_offer_url' must be set when 'units' is greater than 1.
  grafana = {
    units = 3
  }

  # A Juju offer URL of a PostgreSQL service providing the 'postgresql_client'
  # integration. Set to 'null' to fall back to the default per-unit Juju storage.
  postgresql_offer_url = "admin/postgresql.database"
}

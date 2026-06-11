mock_provider "juju" {}

variables {
  model         = { uuid = "00000000-0000-0000-0000-000000000000" }
  s3_endpoint   = "foo"
  s3_access_key = "foo"
  s3_secret_key = "foo"
}

# --- grafana: scaled > 1 requires database offer ---

run "grafana_requires_database_offer" {
  command = plan

  variables {
    grafana = {
      units = 3
    }
  }

  expect_failures = [var.postgresql_offer_url]
}

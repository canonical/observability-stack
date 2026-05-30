mock_provider "juju" {}

# --- model: create when no uuid provided ---

run "model_created_when_no_uuid" {
  command = plan

  assert {
    condition     = length(juju_model.cos) == 1
    error_message = "Expected juju_model.cos to be created when no UUID is provided"
  }

  assert {
    condition     = length(data.juju_model.cos) == 0
    error_message = "Expected no data source lookup when creating a model"
  }

  assert {
    condition     = juju_model.cos[0].name == "cos-lite"
    error_message = "Expected default model name to be 'cos-lite'"
  }
}

# --- model: custom name and cloud ---

run "model_created_with_custom_config" {
  command = plan

  variables {
    model = {
      name = "my-observability"
      cloud = {
        name   = "microk8s"
        region = "localhost"
      }
      config = {
        logging-config = "<root>=DEBUG"
      }
      create_timeout = "60m"
    }
  }

  assert {
    condition     = juju_model.cos[0].name == "my-observability"
    error_message = "Expected model name to be 'my-observability'"
  }

  assert {
    condition     = length(data.juju_model.cos) == 0
    error_message = "Expected no data source when creating model"
  }
}

# --- model: lookup existing via var.model.uuid ---

run "model_looked_up_when_uuid_provided" {
  command = plan

  variables { model = { uuid = "12345678-1234-1234-1234-123456789abc" } }

  assert {
    condition     = length(juju_model.cos) == 0
    error_message = "Expected no juju_model resource when UUID is provided"
  }

  assert {
    condition     = length(data.juju_model.cos) == 1
    error_message = "Expected data source lookup when UUID is provided"
  }
}

# --- model: lookup existing via deprecated var.model_uuid ---

run "model_looked_up_via_legacy_variable" {
  command = plan

  variables { model_uuid = "abcdef01-2345-6789-abcd-ef0123456789" }

  assert {
    condition     = length(juju_model.cos) == 0
    error_message = "Expected no juju_model resource when legacy model_uuid is provided"
  }

  assert {
    condition     = length(data.juju_model.cos) == 1
    error_message = "Expected data source lookup when legacy model_uuid is provided"
  }
}

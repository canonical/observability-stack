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
        logging-config = "<root>=WARNING; unit=DEBUG"
      }
    }
  }

  assert {
    condition     = juju_model.cos[0].name == "my-observability"
    error_message = "Expected model name to be 'my-observability'"
  }

  assert {
    condition     = juju_model.cos[0].cloud[0].name == "microk8s"
    error_message = "Expected cloud name to be 'microk8s'"
  }

  assert {
    condition     = juju_model.cos[0].cloud[0].region == "localhost"
    error_message = "Expected cloud region to be 'localhost'"
  }

  assert {
    condition     = juju_model.cos[0].config["logging-config"] == "<root>=WARNING; unit=DEBUG"
    error_message = "Expected logging-config to be '<root>=WARNING; unit=DEBUG'"
  }

  assert {
    condition     = length(data.juju_model.cos) == 0
    error_message = "Expected no data source when creating model"
  }
}

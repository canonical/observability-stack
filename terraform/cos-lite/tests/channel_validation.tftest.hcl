mock_provider "juju" {}

variables {
  model_uuid = "00000000-0000-0000-0000-000000000000"
}

# ---Happy path---

run "valid_channel_stable" {
  command = plan
  variables { channel = "2/stable" }
}

run "valid_channel_candidate" {
  command = plan
  variables { channel = "2/candidate" }
}

run "valid_channel_beta" {
  command = plan
  variables { channel = "2/beta" }
}

run "valid_channel_edge" {
  command = plan
  variables { channel = "2/edge" }
}

# ---Failure path---
# NOTE: Invalid risks (e.g. "2/risk") are validated by the Juju provider at the
# resource level inside child modules. Terraform test's expect_failures cannot
# reference resources inside child modules, so we cannot assert on that here.

run "invalid_channel_track_1" {
  command = plan
  variables { channel = "1/stable" }
  expect_failures = [var.channel]
}

run "invalid_channel_track_dev" {
  command = plan
  variables { channel = "dev/stable" }
  expect_failures = [var.channel]
}

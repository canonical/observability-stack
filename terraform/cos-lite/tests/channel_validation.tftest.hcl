mock_provider "juju" {}

variables { model_uuid = "00000000-0000-0000-0000-000000000000" }

# ---Happy path---

run "valid_channel_stable" {
  command = plan
  variables { channel = "dev/stable" }
}

run "valid_channel_candidate" {
  command = plan
  variables { channel = "dev/candidate" }
}

run "valid_channel_beta" {
  command = plan
  variables { channel = "dev/beta" }
}

run "valid_channel_edge" {
  command = plan
  variables { channel = "dev/edge" }
}

# ---Failure path---
# NOTE: Invalid risks (e.g. "dev/risk") are validated by the Juju provider at the
# resource level inside child modules. Terraform test's expect_failures cannot
# reference resources inside child modules, so we cannot assert on that here.

run "invalid_channel_track_2" {
  command = plan
  variables { channel = "2/stable" }
  expect_failures = [var.channel]
}

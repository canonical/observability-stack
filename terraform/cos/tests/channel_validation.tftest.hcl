# ---Happy path---

run "valid_channel_track" {
  command = plan

  variables {
    channel       = "2/stable"
    model_uuid    = "00000000-0000-0000-0000-000000000000"
    s3_endpoint   = "foo"
    s3_access_key = "foo"
    s3_secret_key = "foo"
  }
}

run "valid_channel_stable" {
  command = plan

  variables {
    channel       = "2/candidate"
    model_uuid    = "00000000-0000-0000-0000-000000000000"
    s3_endpoint   = "foo"
    s3_access_key = "foo"
    s3_secret_key = "foo"
  }
}

run "valid_channel_candidate" {
  command = plan

  variables {
    channel       = "2/beta"
    model_uuid    = "00000000-0000-0000-0000-000000000000"
    s3_endpoint   = "foo"
    s3_access_key = "foo"
    s3_secret_key = "foo"
  }
}

run "valid_channel_beta" {
  command = plan

  variables {
    channel       = "2/edge"
    model_uuid    = "00000000-0000-0000-0000-000000000000"
    s3_endpoint   = "foo"
    s3_access_key = "foo"
    s3_secret_key = "foo"
  }
}

# ---Failure path---

run "invalid_channel_track" {
  command = plan

  variables {
    channel       = "1/stable"
    model_uuid    = "00000000-0000-0000-0000-000000000000"
    s3_endpoint   = "foo"
    s3_access_key = "foo"
    s3_secret_key = "foo"
  }

  expect_failures = [var.channel]
}

run "invalid_channel_track_numeric" {
  command = plan

  variables {
    channel       = "123/risk"
    model_uuid    = "00000000-0000-0000-0000-000000000000"
    s3_endpoint   = "foo"
    s3_access_key = "foo"
    s3_secret_key = "foo"
  }

  expect_failures = [var.channel]
}

run "invalid_channel_track_string" {
  command = plan

  variables {
    channel       = "foo/risk"
    model_uuid    = "00000000-0000-0000-0000-000000000000"
    s3_endpoint   = "foo"
    s3_access_key = "foo"
    s3_secret_key = "foo"
  }

  expect_failures = [var.channel]
}

run "invalid_channel_track_dev" {
  command = plan

  variables {
    channel       = "dev/risk"
    model_uuid    = "00000000-0000-0000-0000-000000000000"
    s3_endpoint   = "foo"
    s3_access_key = "foo"
    s3_secret_key = "foo"
  }

  expect_failures = [var.channel]
}

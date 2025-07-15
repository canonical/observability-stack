module "cos-lite" {
  source          = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model           = "cos"
  channel         = "1/stable"
  ssc = {
    channel = "1/stable"
  }
  traefik = {
    channel = "latest/edge" # https://github.com/canonical/observability-libs/pull/124
  }
}

module "cos-lite" {
  source          = "git::https://github.com/canonical/observability-stack//terraform/cos-lite"
  model           = "cos"
  channel         = "1/stable"
  ssc_channel     = "1/stable"
  traefik_channel = "latest/stable"
}

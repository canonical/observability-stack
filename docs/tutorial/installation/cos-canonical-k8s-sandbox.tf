module "cos" {
  source          = "git::https://github.com/canonical/observability-stack//terraform/cos"
  model           = "cos"
  channel         = "1/stable"
  s3_endpoint     = "http://s3-endpoint:8080" # Change this to your s3 endpoint
  s3_secret_key   = "secret-key"
  s3_access_key   = "access-key"
  loki_bucket     = "loki"
  mimir_bucket    = "mimir"
  tempo_bucket    = "tempo"
  ssc_channel     = "1/stable"
  traefik_channel = "latest/stable"
  anti_affinity   = true
}

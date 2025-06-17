module "cos" {
  source        = "git::https://github.com/canonical/observability-stack//terraform/cos?ref=feat/tf-migration"
  model         = "cos-2"
  channel       = "1/stable"
  s3_endpoint   = "http://192.168.88.12:8080"
  s3_secret_key = "secret-key"
  s3_access_key = "access-key"
  loki_bucket   = "loki"
  mimir_bucket  = "mimir"
  tempo_bucket  = "tempo"
  ssc_channel   = "1/stable"
  anti_affinity = true
}

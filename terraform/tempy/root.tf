module "cos-lite" {
  source                          = "../cos-lite"
  channel                         = "1/stable"
  model                           = "cos"
  internal_tls                    = true
  external_certificates_offer_url = null

  # All charms expose these configs:
  alertmanager = {
    app_name           = "alertmanager"
    config             = {}
    constraints        = "arch=amd64"
    revision           = null
    storage_directives = {}
    units              = 1
  }
  # SSC and Traefik are non-o11y charms, so we also expose their channels:
  ssc = {
    channel = "1/stable"
  }
  traefik = {
    channel = "latest/edge" # https://github.com/canonical/observability-libs/pull/124
  }
}

module "cos" {
  source                          = "../cos"
  model                           = "cos"
  cloud                           = "self-managed"
  channel                         = "1/stable"
  anti_affinity                   = false
  internal_tls                    = true
  external_certificates_offer_url = null

  s3_endpoint   = "http://S3_IP:8080"
  s3_secret_key = "secret-key"
  s3_access_key = "access-key"
  loki_bucket   = "loki"
  mimir_bucket  = "mimir"
  tempo_bucket  = "tempo"

  # All charms expose these configs):
  alertmanager = {
    config             = {}
    constraints        = "arch=amd64"
    revision           = null
    storage_directives = {}
    units              = 1
  }
  # The S3-integrator config for all coordinated-workers (Loki, Mimir, Tempo) charms:
  s3_integrator = {
    channel            = "2/edge"
    config             = {}
    constraints        = "arch=amd64"
    revision           = 157 # FIXME: https://github.com/canonical/observability/issues/342
    storage_directives = {}
    units              = 1
  }
  # The coordinated-worker (Loki, Mimir, Tempo) charms are special:
  loki_coordinator = {
    config             = {}
    constraints        = "arch=amd64"
    revision           = null
    storage_directives = {}
    units              = 3
  }
  loki_worker = {
    backend_config     = {}
    read_config        = {}
    write_config       = {}
    constraints        = "arch=amd64"
    revision           = null
    storage_directives = {}
    backend_units      = 3
    read_units         = 3
    write_units        = 3
  }
  # SSC and Traefik are non-o11y charms, so we also expose their channels:
  ssc = { channel = "1/stable" }
  traefik = {
    channel = "latest/edge" # https://github.com/canonical/observability-libs/pull/124
  }
}

terraform {
  required_version = ">= 1.5"
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 0.14.0"
    }
  }
}

module "cos" {
  source                 = "../cos"
  model                  = "cos"
  channel                = "2/edge"
  s3_integrator_channel  = "2/edge"
  s3_endpoint            = "http://192.168.5.126:8080"
  s3_secret_key          = "secret-key"
  s3_access_key          = "access-key"
  loki_bucket            = "loki"
  mimir_bucket           = "mimir"
  tempo_bucket           = "tempo"
  anti_affinity          = false
  internal_tls           = false
  # TODO why does `tfa` expect each charm variable as input, but actually just default ...
  alertmanager = {
    app_name = "am"
  }
  loki_coordinator = {
    units = 1
  }
  loki_worker = {
    backend_units = 1
    read_units = 1
    write_units = 1
  }
  mimir_coordinator = {
    units = 1
  }
  mimir_worker = {
    backend_units = 1
    read_units = 1
    write_units = 1
  }
  tempo_coordinator = {
    units = 1
  }
  tempo_worker = {
    compactor_units = 1
    distributor_units = 1
    ingester_units = 1
    metrics_generator_units = 1
    querier_units = 1
    query_frontend_units = 1
  }
  traefik = {
    channel = "latest/edge" # https://github.com/canonical/observability-libs/pull/124
  }
}

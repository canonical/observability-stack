# Single-unit deployment of every COS component: a dev/CI-sized topology.

alertmanager = { units = 1 }
grafana      = { units = 1 }

loki_coordinator = { units = 1 }
loki_worker = {
  backend_units = 1
  read_units    = 1
  write_units   = 1
}

mimir_coordinator = { units = 1 }
mimir_worker = {
  backend_units = 1
  read_units    = 1
  write_units   = 1
}

tempo_coordinator = { units = 1 }
tempo_worker = {
  compactor_units         = 1
  distributor_units       = 1
  ingester_units          = 1
  metrics_generator_units = 1
  querier_units           = 1
  query_frontend_units    = 1
}

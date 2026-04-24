monolithic    = true
anti_affinity = false
risk          = "edge"

loki_coordinator = {
  units = 1
}

mimir_coordinator = {
  units = 1
}

tempo_coordinator = {
  units = 1
}

loki_worker = {
  all_units = 1
}

mimir_worker = {
  all_units = 1
}

tempo_worker = {
  all_units = 1
}

# -------------- # Presets --------------
#
# A preset is a committed, named value file under `presets/`. Selecting one with
# `preset = "<name>"` overrides the module defaults for the fields the preset
# declares; every other field keeps the caller's value (or the module default).
#
# Objects merge field-by-field, so a preset can set `units` without disturbing a
# caller's `config`, `resources`, or `storage_directives`. A scalar is replaced
# wholesale when the preset declares it.
#
# The preset surface is deliberately limited to deployment shape (component
# sizing and enablement). Credentials, endpoints, offer URLs, buckets, and the
# model are *not* preset-addressable: those are environment-specific or
# sensitive, and belong in the caller's arguments (or a gitignored var-file).
#
# Each file is also a plain Terraform JSON variable file, so it can be applied
# directly when this module is the root:
#
#   terraform apply -var-file=presets/units.tfvars.json
#
# See the "Presets" section of the module README.

variable "preset" {
  type        = string
  default     = null
  description = "Name of a preset under presets/ to apply. See the module README."

  validation {
    condition = var.preset == null || contains(
      [for f in fileset("${path.module}/presets", "*.tfvars.json") : trimsuffix(f, ".tfvars.json")],
      var.preset
    )
    error_message = "Unknown preset ${coalesce(var.preset, "null")}. Available presets: ${join(", ", [for f in fileset("${path.module}/presets", "*.tfvars.json") : trimsuffix(f, ".tfvars.json")])}."
  }
}

locals {
  # Empty when no preset is selected, so every `try(local.preset.<key>, ...)`
  # below falls back to the caller's value.
  preset = var.preset == null ? {} : jsondecode(file("${path.module}/presets/${var.preset}.tfvars.json"))
}

locals {
  # Effective values: the caller's arguments (and module defaults) with the
  # selected preset layered on top. Everything downstream reads `local.values`
  # rather than `var.*` so a preset is visible everywhere.
  values = {
    # Scalars: the preset replaces the caller's value when it declares one.
    anti_affinity = try(local.preset.anti_affinity, var.anti_affinity)
    internal_tls  = try(local.preset.internal_tls, var.internal_tls)

    # Objects: merge field-by-field so a preset adjusts one attribute without
    # discarding the rest.
    ingress                 = merge(var.ingress, try(local.preset.ingress, {}))
    alertmanager            = merge(var.alertmanager, try(local.preset.alertmanager, {}))
    catalogue               = merge(var.catalogue, try(local.preset.catalogue, {}))
    grafana                 = merge(var.grafana, try(local.preset.grafana, {}))
    loki_coordinator        = merge(var.loki_coordinator, try(local.preset.loki_coordinator, {}))
    loki_worker             = merge(var.loki_worker, try(local.preset.loki_worker, {}))
    mimir_coordinator       = merge(var.mimir_coordinator, try(local.preset.mimir_coordinator, {}))
    mimir_worker            = merge(var.mimir_worker, try(local.preset.mimir_worker, {}))
    opentelemetry_collector = merge(var.opentelemetry_collector, try(local.preset.opentelemetry_collector, {}))
    s3_integrator           = merge(var.s3_integrator, try(local.preset.s3_integrator, {}))
    ssc                     = merge(var.ssc, try(local.preset.ssc, {}))
    tempo_coordinator       = merge(var.tempo_coordinator, try(local.preset.tempo_coordinator, {}))
    tempo_worker            = merge(var.tempo_worker, try(local.preset.tempo_worker, {}))
    traefik                 = merge(var.traefik, try(local.preset.traefik, {}))
  }
}

# -------------- # Effective-value constraints --------------
#
# These cross-field rules used to be variable validations, but they must reason
# about the effective values (a preset can change `grafana.units` or `ingress`),
# and variable validation cannot read locals. A `terraform_data` precondition
# keeps them hard failures at plan time.

resource "terraform_data" "effective_input_constraints" {
  input = var.preset

  lifecycle {
    precondition {
      # Guard against typos silently no-op'ing: a preset may only set keys the
      # module actually reads. Nested keys are not checked here; the module's
      # own tests exercise the shipped presets.
      condition     = length(setsubtract(keys(local.preset), keys(local.values))) == 0
      error_message = "Preset ${coalesce(var.preset, "null")} sets unknown keys: ${join(", ", setsubtract(keys(local.preset), keys(local.values)))}. Addressable keys: ${join(", ", keys(local.values))}."
    }

    precondition {
      condition     = local.values.grafana.units <= 1 || var.postgresql_offer_url != null
      error_message = "postgresql_offer_url must be supplied when Grafana is scaled > 1 due to its database requirements."
    }

    precondition {
      condition     = !(local.values.ingress.opentelemetry_collector == true && local.values.ingress.tempo == true)
      error_message = "ingress.opentelemetry_collector and ingress.tempo cannot both be enabled. See https://github.com/canonical/observability-stack/issues/382"
    }
  }
}

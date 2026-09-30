output "model_name" {
  value       = local.model_name
  description = "Name of the model this solution was deployed into (used by the solution smoke test to connect via jubilant)"
}

output "internal_tls" {
  value       = var.internal_tls
  description = "Which TLS mode this wrapper was applied with, read back by steps/tls.py instead of a separate mode tag"
}

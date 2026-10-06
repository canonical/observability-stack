output "model_name" {
  value       = local.model_name
  description = "Name of the model this solution was deployed into (used by the solution smoke test to connect via jubilant)"
}

output "internal_tls" {
  value       = var.internal_tls
  description = "Whether internal COS communication uses TLS in this deployment"
}

output "ingress_enabled" {
  value       = anytrue(values(var.ingress))
  description = "Whether any component has ingress enabled in this deployment"
}

output "ingress" {
  value       = var.ingress
  description = "Per-component ingress toggle state, as configured for this deployment"
}

output "ca_model_name" {
  value       = var.external_ca ? local.ca_model_name : null
  description = "Name of the external-CA model, null unless deployed in tls_full/tls_external."
}

output "tls_termination" {
  value       = var.external_ca
  description = "Whether an external CA is terminating TLS for this deployment."
}

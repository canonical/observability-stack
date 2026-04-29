output "app_name" {
  value       = juju_application.seaweedfs.name
  description = "The name of the deployed SeaweedFS application"
}

output "provides" {
  value = {
    s3 = "s3"
  }
  description = "All Juju integration endpoints where the charm is the provider"
}

output "requires" {
  value       = {}
  description = "All Juju integration endpoints where the charm is the requirer"
}

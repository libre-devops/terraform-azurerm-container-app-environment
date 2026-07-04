output "container_app_environment_ids" {
  description = "Map of environment name to id."
  value       = { for k, e in azurerm_container_app_environment.this : k => e.id }
}

output "container_app_environment_ids_zipmap" {
  description = "Map of environment name to { name, id } for easy composition (feed a container app module)."
  value       = { for k, e in azurerm_container_app_environment.this : k => { name = e.name, id = e.id } }
}

output "container_app_environments" {
  description = "Map of environment name to the full container app environment object. Sensitive as a whole because the object can carry the dapr Application Insights connection string; the ids, domains, and identity maps alongside stay plain for composition."
  value       = azurerm_container_app_environment.this
  sensitive   = true
}

output "default_domains" {
  description = "Map of environment name to its default domain (the suffix container app ingress hostnames get)."
  value       = { for k, e in azurerm_container_app_environment.this : k => e.default_domain }
}

output "identity_principal_ids" {
  description = "Map of environment name to { system_assigned } principal id (null where absent)."
  value = {
    for k, e in azurerm_container_app_environment.this : k => {
      system_assigned = try(e.identity[0].principal_id, null)
    }
  }
}

output "static_ip_addresses" {
  description = "Map of environment name to its static IP address."
  value       = { for k, e in azurerm_container_app_environment.this : k => e.static_ip_address }
}

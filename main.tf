locals {
  rg = provider::azurerm::parse_resource_id(var.resource_group_id)
}

resource "azurerm_container_app_environment" "this" {
  for_each = var.container_app_environments

  resource_group_name = local.rg.resource_group_name
  location            = var.location
  tags                = merge(var.tags, coalesce(each.value.tags, {}))

  name                                        = each.key
  log_analytics_workspace_id                  = each.value.log_analytics_workspace_id
  infrastructure_subnet_id                    = each.value.infrastructure_subnet_id
  infrastructure_resource_group_name          = each.value.infrastructure_resource_group_name
  internal_load_balancer_enabled              = each.value.internal_load_balancer_enabled
  zone_redundancy_enabled                     = each.value.zone_redundancy_enabled
  mutual_tls_enabled                          = each.value.mutual_tls_enabled
  dapr_application_insights_connection_string = each.value.dapr_application_insights_connection_string

  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "workload_profile" {
    for_each = each.value.workload_profiles

    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = workload_profile.value.minimum_count
      maximum_count         = workload_profile.value.maximum_count
    }
  }
}

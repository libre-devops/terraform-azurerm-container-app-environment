# The module's surface: an environment wired to a Log Analytics workspace (console and system
# logs land there), a workload-profile environment with the Consumption profile, and a
# system-assigned identity. VNet integration and an internal load balancer are exposed by the
# module but not exercised here (they need a delegated /23 subnet, which is caller topology).
# Applied then destroyed in one CI run.
locals {
  location = lookup(var.regions, var.loc, "uksouth")
  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
  law_name = "log-${var.short}-${var.loc}-${terraform.workspace}-002"
  cae_name = "cae-${var.short}-${var.loc}-${terraform.workspace}-002"
}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
  additional_tags = { Application = "terraform-azurerm-container-app-environment" }
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

module "log_analytics" {
  source  = "libre-devops/log-analytics-workspace/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  log_analytics_workspaces = { (local.law_name) = {} }
}

module "container_app_environment" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  container_app_environments = {
    (local.cae_name) = {
      log_analytics_workspace_id = module.log_analytics.workspace_ids[local.law_name]

      identity = { type = "SystemAssigned" }

      # The Consumption profile turns this into a workload-profile environment (the structure that
      # can also host dedicated or GPU profiles) without provisioning any dedicated compute.
      workload_profiles = [
        { name = "Consumption", workload_profile_type = "Consumption" }
      ]
    }
  }
}

output "default_domain" {
  value = module.container_app_environment.default_domains[local.cae_name]
}

output "environment_id" {
  value = module.container_app_environment.container_app_environment_ids[local.cae_name]
}

output "resource_group_name" {
  value = local.rg_name
}

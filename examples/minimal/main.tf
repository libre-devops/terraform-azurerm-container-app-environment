# Minimal call: one Consumption-only managed environment (Azure Monitor logs). Applied then
# destroyed in one CI run.
locals {
  location = lookup(var.regions, var.loc, "uksouth")
  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-001"
  cae_name = "cae-${var.short}-${var.loc}-${terraform.workspace}-001"
}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

module "container_app_environment" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  container_app_environments = {
    (local.cae_name) = {}
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

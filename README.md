<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Container App Environment

Terraform module for the Azure Container Apps managed environment, in the Libre DevOps style:
fast to get going, secure by default, flexible when it matters. This is the foundation a
`libre-devops/container-app/azurerm` module deploys apps into.

[![CI](https://github.com/libre-devops/terraform-azurerm-container-app-environment/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-container-app-environment/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-container-app-environment?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-container-app-environment/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-container-app-environment)](./LICENSE)

---

## Overview

```hcl
module "container_app_environment" {
  source  = "libre-devops/container-app-environment/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids["rg-ldo-uks-dev-001"]
  location          = "uksouth"
  tags              = module.tags.tags

  container_app_environments = {
    "cae-ldo-uks-dev-001" = {}
  }
}
```

That single entry gets a Consumption-only managed environment. Every knob is an explicit
override, and the outputs (`container_app_environment_ids_zipmap`, `default_domains`) are shaped
to feed straight into a container app module.

- **Environments as a map.** Provision many environments in one call via `for_each`.
- **Logs where you want them.** Pass `log_analytics_workspace_id` to ship container app console
  and system logs to your workspace; without it the environment uses Azure Monitor only.
- **Private when you need it.** `infrastructure_subnet_id` places the environment in your VNet
  (the subnet needs a /23 or larger with the `Microsoft.App` delegation), and
  `internal_load_balancer_enabled` then makes it fully private, a combination a validation
  enforces so you cannot ask for a private environment with no subnet.
- **Workload profiles.** The default is Consumption-only; add `workload_profiles` for dedicated
  or GPU compute. Zone redundancy and an identity (for pulling images or dapr telemetry) are
  there when you want them.

## Examples

- [`examples/minimal`](./examples/minimal) - one Consumption-only environment, applied and
  verified in CI.
- [`examples/complete`](./examples/complete) - an environment wired to a Log Analytics workspace
  with a workload profile and a system-assigned identity.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app_environment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_app_environments"></a> [container\_app\_environments](#input\_container\_app\_environments) | Container app environments keyed by name. Fast to get going: an entry with just a name gets a<br/>Consumption-only environment. Flexible when it matters: wire a Log Analytics workspace for<br/>logs, an infrastructure subnet for VNet integration, workload profiles for dedicated<br/>compute, zone redundancy, and an internal load balancer for a private environment.<br/><br/>LOGS: pass log\_analytics\_workspace\_id to ship container app console and system logs there;<br/>without it the environment uses Azure Monitor only. VNET: infrastructure\_subnet\_id places the<br/>environment in your VNet (the subnet needs a /23 or larger and the Microsoft.App delegation);<br/>internal\_load\_balancer\_enabled then makes the environment private (no public ingress).<br/>WORKLOAD PROFILES: the default is Consumption-only; add profiles for dedicated or GPU compute<br/>(a workload\_profile with a Consumption entry is required alongside dedicated ones). | <pre>map(object({<br/>    log_analytics_workspace_id                  = optional(string)<br/>    infrastructure_subnet_id                    = optional(string)<br/>    infrastructure_resource_group_name          = optional(string)<br/>    internal_load_balancer_enabled              = optional(bool)<br/>    zone_redundancy_enabled                     = optional(bool)<br/>    mutual_tls_enabled                          = optional(bool)<br/>    dapr_application_insights_connection_string = optional(string)<br/><br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string))<br/>    }))<br/><br/>    workload_profiles = optional(list(object({<br/>      name                  = string<br/>      workload_profile_type = string<br/>      minimum_count         = optional(number)<br/>      maximum_count         = optional(number)<br/>    })), [])<br/><br/>    tags = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for all environments in this module. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Id of the resource group the environments live in; the module parses the name from it. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all environments; per-environment tags override these. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_environment_ids"></a> [container\_app\_environment\_ids](#output\_container\_app\_environment\_ids) | Map of environment name to id. |
| <a name="output_container_app_environment_ids_zipmap"></a> [container\_app\_environment\_ids\_zipmap](#output\_container\_app\_environment\_ids\_zipmap) | Map of environment name to { name, id } for easy composition (feed a container app module). |
| <a name="output_container_app_environments"></a> [container\_app\_environments](#output\_container\_app\_environments) | Map of environment name to the full container app environment object. Sensitive as a whole because the object can carry the dapr Application Insights connection string; the ids, domains, and identity maps alongside stay plain for composition. |
| <a name="output_default_domains"></a> [default\_domains](#output\_default\_domains) | Map of environment name to its default domain (the suffix container app ingress hostnames get). |
| <a name="output_identity_principal_ids"></a> [identity\_principal\_ids](#output\_identity\_principal\_ids) | Map of environment name to { system\_assigned } principal id (null where absent). |
| <a name="output_static_ip_addresses"></a> [static\_ip\_addresses](#output\_static\_ip\_addresses) | Map of environment name to its static IP address. |
<!-- END_TF_DOCS -->

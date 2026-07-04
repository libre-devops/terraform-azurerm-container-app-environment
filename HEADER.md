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

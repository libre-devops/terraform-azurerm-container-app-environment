# Tests for the module. azurerm is mocked (no credentials, no cloud):
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {}

variables {
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001"
  location          = "uksouth"
  tags              = { Environment = "tst" }
}

# One environment, nothing but a name: a Consumption-only managed environment.
run "fast_to_get_going" {
  command = apply

  variables {
    container_app_environments = {
      "cae-ldo-uks-tst-001" = {}
    }
  }

  assert {
    condition     = azurerm_container_app_environment.this["cae-ldo-uks-tst-001"].name == "cae-ldo-uks-tst-001"
    error_message = "The environment should be created."
  }

  assert {
    condition     = length(azurerm_container_app_environment.this["cae-ldo-uks-tst-001"].workload_profile) == 0
    error_message = "No workload profiles by default (Consumption-only)."
  }
}

# A VNet-integrated environment with a workspace, a workload profile, and zone redundancy.
run "vnet_integrated_with_profile" {
  command = apply

  variables {
    container_app_environments = {
      "cae-ldo-uks-tst-002" = {
        log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001/providers/Microsoft.OperationalInsights/workspaces/log-mock"
        infrastructure_subnet_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet-cae"
        zone_redundancy_enabled    = true
        workload_profiles = [
          { name = "Consumption", workload_profile_type = "Consumption" },
          { name = "dedicated-d4", workload_profile_type = "D4", minimum_count = 1, maximum_count = 3 },
        ]
      }
    }
  }

  assert {
    condition     = length(azurerm_container_app_environment.this["cae-ldo-uks-tst-002"].workload_profile) == 2
    error_message = "Both workload profiles should be configured."
  }

  assert {
    condition     = azurerm_container_app_environment.this["cae-ldo-uks-tst-002"].zone_redundancy_enabled == true
    error_message = "Zone redundancy should be enabled."
  }
}

# A private environment needs a subnet.
run "rejects_internal_lb_without_subnet" {
  command = plan

  variables {
    container_app_environments = {
      "cae-ldo-uks-tst-003" = {
        internal_load_balancer_enabled = true
      }
    }
  }

  expect_failures = [var.container_app_environments]
}

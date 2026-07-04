variable "container_app_environments" {
  description = <<-DESC
    Container app environments keyed by name. Fast to get going: an entry with just a name gets a
    Consumption-only environment. Flexible when it matters: wire a Log Analytics workspace for
    logs, an infrastructure subnet for VNet integration, workload profiles for dedicated
    compute, zone redundancy, and an internal load balancer for a private environment.

    LOGS: pass log_analytics_workspace_id to ship container app console and system logs there;
    without it the environment uses Azure Monitor only. VNET: infrastructure_subnet_id places the
    environment in your VNet (the subnet needs a /23 or larger and the Microsoft.App delegation);
    internal_load_balancer_enabled then makes the environment private (no public ingress).
    WORKLOAD PROFILES: the default is Consumption-only; add profiles for dedicated or GPU compute
    (a workload_profile with a Consumption entry is required alongside dedicated ones).
  DESC
  type = map(object({
    log_analytics_workspace_id                  = optional(string)
    infrastructure_subnet_id                    = optional(string)
    infrastructure_resource_group_name          = optional(string)
    internal_load_balancer_enabled              = optional(bool)
    zone_redundancy_enabled                     = optional(bool)
    mutual_tls_enabled                          = optional(bool)
    dapr_application_insights_connection_string = optional(string)

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    workload_profiles = optional(list(object({
      name                  = string
      workload_profile_type = string
      minimum_count         = optional(number)
      maximum_count         = optional(number)
    })), [])

    tags = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for e in values(var.container_app_environments) :
      !coalesce(e.internal_load_balancer_enabled, false) || e.infrastructure_subnet_id != null
    ])
    error_message = "internal_load_balancer_enabled requires an infrastructure_subnet_id (a private environment must be VNet-integrated)."
  }
}

variable "location" {
  description = "Azure region for all environments in this module."
  type        = string
}

variable "resource_group_id" {
  description = "Id of the resource group the environments live in; the module parses the name from it."
  type        = string
}

variable "tags" {
  description = "Tags applied to all environments; per-environment tags override these."
  type        = map(string)
  default     = {}
}

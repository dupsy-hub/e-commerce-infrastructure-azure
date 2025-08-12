
# Vmss configuration for compute team

locals {
  # Map of admin passwords for each VMSS instance
  # Pulled from sensitive Terraform Cloud variables
  admin_passwords = {
    teleios = var.teleios_admin_password
    chris   = var.chris_admin_password
    dupe    = var.dupe_admin_password
  }

  # Final merged VMSS configuration
  # Combines user-supplied config with subnet ID, backend pool ID, and password
  merged_vmss_config = {
    for k, config in var.vmss_config :
    k => merge(config, {
      # Use the subnet ID from the data block (same for all instances)
      subnet_id = module.vnet.subnet_ids[var.vmss_subnet_key],       # Shared subnet from data block

      # Lookup backend pool from Application Gateway based on name
      backend_pool_id = module.app-gateway.vmss_backend_pool_id,

      # Inject the correct admin password per VMSS instance
      admin_password = local.admin_passwords[k]
    })
  }
}



locals {
  # Replace placeholders in NSGs from tfvars
  nsgs_with_cidr_from_tfvars = {
    for tier, cfg in var.nsgs :
    tier => {
      rules = [
        for rule in cfg.rules :
        rule.source_address_prefix == "vnet_cidr"
        ? merge(rule, { source_address_prefix = module.vnet.vnet_cidr })
        : rule
      ]
    }
  }

  # API NSG rules (generated from Web subnets)
  api_nsg = {
    rules = [
      for cidr in module.vnet.subnet_cidrs_by_tier["web"] : {
        name                       = substr("Allow-API-from-Web-${replace(cidr, "/", "-")}", 0, 80)
        priority                   = 100 + index(module.vnet.subnet_cidrs_by_tier["web"], cidr)
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = cidr
        destination_address_prefix = "*"
      }
    ]
  }

  # Data NSG rules (generated from API subnets)
  data_nsg = {
    rules = [
      for cidr in module.vnet.subnet_cidrs_by_tier["api"] : {
        name                       = substr("Allow-DB-from-API-${replace(cidr, "/", "-")}", 0, 80)
        priority                   = 100 + index(module.vnet.subnet_cidrs_by_tier["api"], cidr)
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = cidr
        destination_address_prefix = "*"
      }
    ]
  }

  # Merge tfvars config with generated NSGs
  final_nsgs = merge(
    local.nsgs_with_cidr_from_tfvars,
    { api  = local.api_nsg },
    { data = local.data_nsg }
  )
}


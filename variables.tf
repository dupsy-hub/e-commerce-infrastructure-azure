#--- Global Variables ---
variable "resource_group_name" {
  type = string
}

variable "location" {
  description = "Default location for module not using the new location map"
  type        = string
}
variable "environment" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}


#--- vnet ---
variable "vnet_address_cidr" {
  type        = string
}

variable "nat_gateway_name" {
  type        = string
}

variable "nat_gateway_availability_zones" {
  type        = list(string)
}

# variable "storage_account_name" {
#   description = "Storage resource name"
#   type        = string
# }

# variable "secondary_location" {
#   type = string
# }


variable "subnet_groups" {
  type = map(object({
    count = number
    zone  = string
  }))
  description = "Map of subnet groups with the number of subnets (count) and their availability zone (zone)."
}


variable "use_existing_rg" {
  description = "Check for existing resource group"
  type        = bool
}



#--- Compute section ---

variable "vmss_config" {
  description = "Map of VMSS configurations keyed by name"
  type = map(object({
    vmss_name                     = string
    vm_size                       = string
    instance_count                = number
    admin_username                = string
    image_publisher               = string
    image_offer                   = string
    image_sku                     = string
    image_version                 = string
    os_disk_caching               = string
    os_disk_storage_account_type = string
    upgrade_mode                  = string
    nic_name                      = string
    ip_config_name                = string
  }))
}

# --- Admin Passwords for VMSS Instances ---
variable "teleios_admin_password" {
  description = "Admin password for Teleios VMSS"
  type        = string
  sensitive   = true
}

variable "chris_admin_password" {
  description = "Admin password for Chris VMSS"
  type        = string
  sensitive   = true
}

variable "dupe_admin_password" {
  description = "Admin password for Dupe VMSS"
  type        = string
  sensitive   = true
}


variable "vmss_subnet_key" {
  description = "Key to get correct subnet ID from vnet output"
  type        = string
  default     = "web-subnet-1"
}


variable "vmss_subnet_name" {
  description = "Key to get correct subnet ID from vnet output"
  type        = string
  default     = "web-subnet-1"
}

# --- App Service ---
variable "service_plan_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "os_type" {
  type = string
}

variable "sku_name" {
  type = string
}

variable "enable_identity" {
  type = bool
}

variable "application_stack" {
  type = object({
    dotnet_version      = optional(string)
    java_server         = optional(string)
    java_server_version = optional(string)
    java_version        = optional(string)
    node_version        = optional(string)
    php_version         = optional(string)
    python_version      = optional(string)
    ruby_version        = optional(string)
    current_stack       = optional(string)
  })
}

variable "app_settings" {
  type = map(string)
}

variable "connection_strings" {
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
}

variable "runtime" {
  type = string
}

variable "runtime_version" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "function_app_name" {
  type = string
}

# variable "redis_configs" {
#   description = "User-defined Redis config inputs (raw)"
#   type = map(object({
#     name                          = string
#     sku_name                      = string
#     family                        = string
#     capacity                      = number
#     enable_private_endpoint       = optional(bool)
#     subnet_key                    = optional(string)
#     subnet_id                     = optional(string)
#     enable_non_ssl_port           = optional(bool)
#     public_network_access_enabled = optional(bool)
#     tags                          = optional(map(string))
#   }))
# }


variable "nsgs" {
  description = "Map of NSGs with their rule sets"
  type = map(object({
    rules = list(object({
      name                       = string
      priority                   = number
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}


## data layer such as redis, database, etc
# variable "sql_admin_username" {
#   type    = string
# }


#--- sql section ---
variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "sql_database_name" {
  description = "Name of the SQL Database"
  type        = string
}

variable "sql_max_size_gb" {
  description = "Maximum size of the database in GB"
  type        = number
}

variable "sql_sku_name" {
  description = "SKU for the SQL Database"
  type        = string
}

variable "sql_admin_username" {
  description = "Admin username for SQL Server"
  type        = string
}
variable "sql_admin_password" {
  description = "Admin password for SQL Server (stored securely in Terraform Cloud)"
  type        = string
  sensitive   = true
}

# ---Cosmos DB–specific variables ---
variable "secondary_location" {
  description = "Secondary Azure region for Cosmos DB geo-redundancy"
  type        = string
}

variable "cosmos_account_configs" {
  description = "Map of Cosmos DB account configurations"
  type = map(object({
    name_suffix                  = string
    cosmos_account_name_override = string
    api_kind                     = string
    consistency_level            = string
    max_interval_in_seconds      = number
    max_staleness_prefix         = number
    capabilities                 = list(string)
    geo_locations = list(object({
      location          = string
      failover_priority = number
      zone_redundant    = bool
    }))
    databases = list(object({
      name               = string
      container_name     = string
      partition_key_path = string
      throughput         = number
    }))
  }))
}

variable "cosmos_subnet_key" {
  description = "Key to select the Cosmos DB subnet from the VNet module's subnet_ids output"
  type        = string
}

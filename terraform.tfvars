# General resource

environment         = "dev"
location            = "northeurope"
tags                = { "Environment" = "dev", "Project" = "E-Commerce" }
resource_group_name = "teleios-ecommerce-dev-rg"

#Networking values (vnet, natgateway and nsg)

nat_gateway_availability_zones = ["1", "2", "3"]
nat_gateway_name    = "teleios-dev-natgw"
vnet_address_cidr   = "10.0.0.0/19"
use_existing_rg     = false



nsgs = {
  web = {
    rules = [
      {
        name                       = "Allow-HTTP"
        priority                   = 100
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-HTTPS"
        priority                   = 110
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-SSH-from-Management"
        priority                   = 120
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "vnet_cidr" # placeholder
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-AppGw-Probe-Ports"
        priority                   = 130
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range    = "65200-65535"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
}

    ]
  }
}
 
subnet_groups = {
  web = { count = 1, zone  = "1" }
  api = { count = 1, zone  = "3" }
  data = { count = 1, zone  = "2" }
  gateway = { count = 1, zone  = "2" }
}


# Compute (vms, appservice, etc)

# The name of the subnet key to use for the VMSS instances
vmss_subnet_key = "api-subnet-1"
vmss_subnet_name  = "private-subnet-1"
backend_pool_name = "backend-pool"

# Map of VMSS configurations (one per VMSS)
# Each key (e.g., teleios, chris, dupe) represents a distinct VMSS instance
vmss_config = {
  teleios = {
    vmss_name                    = "teleios-vmss-dev"
    vm_size                      = "Standard_B2s"
    instance_count               = 1
    admin_username               = "teleios"
    image_publisher              = "MicrosoftWindowsServer"
    image_offer                  = "WindowsServer"
    image_sku                    = "2019-Datacenter"
    image_version                = "latest"
    os_disk_caching              = "ReadWrite"
    os_disk_storage_account_type = "Standard_LRS"
    upgrade_mode                 = "Manual"
    nic_name                     = "nic"
    ip_config_name               = "ipconfig"
  }

  chris = {
    vmss_name                    = "chris-vmss-staging"
    vm_size                      = "Standard_B2s"
    instance_count               = 1
    admin_username               = "chris"
    image_publisher              = "MicrosoftWindowsServer"
    image_offer                  = "WindowsServer"
    image_sku                    = "2019-Datacenter"
    image_version                = "latest"
    os_disk_caching              = "ReadWrite"
    os_disk_storage_account_type = "Standard_LRS"
    upgrade_mode                 = "Manual"
    nic_name                     = "chris-nic"
    ip_config_name               = "chris-ip"
  }

  dupe = {
    vmss_name                    = "dupe-vmss-prod"
    vm_size                      = "Standard_B2s"
    instance_count               = 1
    admin_username               = "dupe"
    image_publisher              = "MicrosoftWindowsServer"
    image_offer                  = "WindowsServer"
    image_sku                    = "2019-Datacenter"
    image_version                = "latest"
    os_disk_caching              = "ReadWrite"
    os_disk_storage_account_type = "Standard_LRS"
    upgrade_mode                 = "Manual"
    nic_name                     = "dupe-nic"
    ip_config_name               = "dupe-ip"
  }
}

#-------sql---------
sql_server_name    = "teleios-sql-server-dev"
sql_database_name  = "teleios-ecommerce-db-dev"
sql_max_size_gb    = 2
sql_sku_name       = "Basic"
sql_admin_username = "sqladminuser"

# -----cosmosdb-----
cosmos_account_configs = {
  teleios = {
    name_suffix                  = "ecomdb-teleios"
    cosmos_account_name_override = "teleios-cosmosdb-dev"
    api_kind                     = "GlobalDocumentDB"

    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
    capabilities            = []

    geo_locations = [
      {
        location          = "northeurope"
        failover_priority = 0
        zone_redundant    = false
      },
      {
        location          = "uksouth"
        failover_priority = 1
        zone_redundant    = false
      }
    ]

    databases = [
      {
        name               = "ProductCatalog"
        container_name     = "products"
        partition_key_path = "/productId"
        throughput         = 400
      },
      {
        name               = "ShoppingCarts"
        container_name     = "carts"
        partition_key_path = "/cartId"
        throughput         = 400
      },
      {
        name               = "UserSessions"
        container_name     = "sessions"
        partition_key_path = "/sessionId"
        throughput         = 400
      }
    ]
  }
}

cosmos_subnet_key   = "data-subnet-1"
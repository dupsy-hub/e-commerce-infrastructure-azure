module "cosmos_db" {
  source  = "app.terraform.io/Teleios/cosmos-db/azure"
  version = "1.5.6"

  resource_group_name   = var.resource_group_name
  location              = var.location
  secondary_location    = var.secondary_location
  environment           = var.environment
  tags                  = var.tags
  private_dns_zone_name = "privatelink.documents.azure.com"

  account_configs = {
    for key, config in var.cosmos_account_configs : key => merge(config, {
      location           = var.location,
      secondary_location = var.secondary_location,
      subnet_id          = module.vnet.subnet_ids[var.cosmos_subnet_key],
      virtual_network_id = module.vnet.vnet_id
    })
  }
}

module "nsg" {
  source  = "app.terraform.io/Teleios/nsg/azure"
  version = "1.0.4"
  # insert required variables here

  resource_group_name = module.vnet.resource_group_name
  location            = module.vnet.location
  environment         = var.environment
  tags                = var.tags
  source_cidrs_by_tier    = module.vnet.subnet_cidrs_by_tier
  nsgs                 = local.final_nsgs


}

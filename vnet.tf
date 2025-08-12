module "vnet" {
  source  = "app.terraform.io/Teleios/vnet/azure"
  version = "1.1.1"

  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = "${var.environment}-teleios-ecommerce-vnet"
  vnet_address_space  = var.vnet_address_cidr
  use_existing_rg     = var.use_existing_rg
   nsg_ids            = module.nsg.nsg_ids


  subnet_groups = var.subnet_groups


  nat_gateway_ids_by_zone = module.nat-gateway.nat_gateway_ids_by_zone
  tags = var.tags
}

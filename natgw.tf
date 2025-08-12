module "nat-gateway" {
  source  = "app.terraform.io/Teleios/nat-gateway/azure"
  version = "1.0.7"

  name                    = var.nat_gateway_name
  resource_group_name     = module.vnet.resource_group_name
  location                = module.vnet.location
  idle_timeout_in_minutes = 10
  nat_gateway_count       = 2
  availability_zones      = var.nat_gateway_availability_zones
  tags                    = var.tags

}
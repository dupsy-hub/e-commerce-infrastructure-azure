module "app-gateway" {
  source  = "app.terraform.io/Teleios/app-gateway/azure"
  version = "1.1.3"

  name                = "teleios-appgw-${var.environment}"
  resource_group_name = module.vnet.resource_group_name
  location            = module.vnet.location
  subnet_id           = module.vnet.subnet_ids["web-subnet-1"]
  appservice_fqdn     = module.app_service.web_app_default_hostname

  tags = var.tags


}
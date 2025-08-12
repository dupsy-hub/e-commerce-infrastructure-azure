
module "app_service" {

  source              = "app.terraform.io/Teleios/app-service/azure"
  version             = "1.1.2"
  resource_group_name = module.vnet.resource_group_name
  location            = module.vnet.location
  environment         = var.environment
  service_plan_name   = var.service_plan_name
  service_name        = var.service_name
  os_type             = var.os_type
  sku_name            = var.sku_name
  enable_identity     = var.enable_identity

  application_stack  = var.application_stack
  app_settings       = var.app_settings
  connection_strings = var.connection_strings
  tags               = var.tags
}

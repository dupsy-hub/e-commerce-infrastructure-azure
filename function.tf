
module "functions" {
  source  = "app.terraform.io/Teleios/functions/azure"
  version = "1.1.9"
  resource_group_name                = module.vnet.resource_group_name
  location                           = module.vnet.location
  environment                        = var.environment
  function_app_name                  = var.function_app_name
  storage_account_name               = module.teleios_storage.storage_account_name
  service_plan_id                    = module.app_service.service_plan_id
  os_type                            = var.os_type
  runtime                            = var.runtime
  runtime_version                    = var.runtime_version

  app_settings       = var.app_settings
  tags               = var.tags
  connection_strings = var.connection_strings
}
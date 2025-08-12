module "azure_sql" {
  source  = "app.terraform.io/Teleios/sql/azure"
  version = "1.2.4"

  resource_group_name = module.vnet.resource_group_name
  location            = module.vnet.location
  environment         = var.environment
  tags                = var.tags

  sql_server_name     = var.sql_server_name
  sql_database_name   = var.sql_database_name
  sql_max_size_gb     = var.sql_max_size_gb
  sql_sku_name        = var.sql_sku_name
  sql_admin_username  = var.sql_admin_username
  sql_admin_password  = var.sql_admin_password
}


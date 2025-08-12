module "teleios_storage" {
  source  = "app.terraform.io/Teleios/storage/azure"
  version = "1.2.4"

  storage_account_name     = "teleiosstorageprodx7a9"
  resource_group_name      = module.vnet.resource_group_name
  location                 = module.vnet.location
  environment              = var.environment

  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Project   = "Teleios-Ecommerce"
    Environment = "prod"
    ManagedBy = "Terraform"
    Owner     = "TeleiosTeam"
  }

  containers = {
    "product-images" = "blob"    # public read
    "user-uploads"   = "private" # private
    "static-assets"  = "blob"    # public read
  }

  lifecycle_rules = {
    tier_to_cool_after_days    = 30
    tier_to_archive_after_days = 90
    delete_after_days          = 365
  }
}

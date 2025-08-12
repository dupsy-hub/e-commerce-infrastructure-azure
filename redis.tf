module "redis" {
  source = "app.terraform.io/Teleios/redis/azure"
  version = "1.3.7"

  redis_configs = {
    "redis-public" = {
      name                          = "teleios-redis-${var.environment}"
      location                      = module.vnet.location
      resource_group_name           = module.vnet.resource_group_name
      sku_name                      = "Basic"
      family                        = "C"
      capacity                      = 1
      public_network_access_enabled = true
      enable_private_endpoint       = false
       tags = {
        environment = var.environment
        name        = "teleios-redis-${var.environment}" 
        project     = "Teleios-Ecommerce"
        managed_by  = "Terraform"
        owner       = "TeleiosTeam"
      }
    }  
  }
}
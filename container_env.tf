module "ContainerEnv" {
  source  = "app.terraform.io/Teleios/ContainerEnv/azure"
  version = "1.0.8"

  # Module accepts multiple container app environment definitions via a map If no `name` is specified per environment, it defaults to: "teleios-cae-${each.key}"

  cae_configs = {
    # This creates one container app environment with the key "ContainerEnv-1"
    ContainerEnv-1 = {
      # Optional: if name is not provided, module uses "teleios-cae-ContainerEnv-1"

      name                = "teleios-cae-${var.environment}"
      location            = module.vnet.location
      resource_group_name = module.vnet.resource_group_name

      # Subnet used for internal infrastructure communication
      infrastructure_subnet_id = module.vnet.subnet_ids["data-subnet-1"]

      tags = {
        environment = var.environment
        name        = "teleios-containerenv-1-${var.environment}" 
        project     = "Teleios-Ecommerce"
        managed_by  = "Terraform"
        owner       = "TeleiosTeam"
      }
    }
  }
}
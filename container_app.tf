module "container_app" {
  source  = "app.terraform.io/Teleios/ContainerApp/azure"
  version = "1.0.6"

  location            = module.vnet.location
  resource_group_name = module.vnet.resource_group_name
  environment_id      = module.ContainerEnv.containerapp_envs_ids["ContainerEnv-1"]

  container_apps = {
    inventory-service = {
      image        = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"

      ingress = {
        external_enabled = true
        target_port      = 80
      }

      traffic_weight = [
        {
          percentage      = 100
          latest_revision = true
        }
      ]

      # Optional environment variables
      # env_vars = {
      #   ENVIRONMENT = "prod"
      #   API_KEY     = "secret"
      # }

      tags = {
        Project     = "Teleios-Ecommerce"
        Environment = "Prod"
        ManagedBy   = "Terraform"
        Owner       = "TeleiosTeam"
        name        = "teleios-inventory-service-app-${var.environment}"
      }
    }

    payment-service = {
      image        = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
      cpu          = 0.25
      memory       = "0.5Gi"

      ingress = {
        external_enabled = true
        target_port      = 80
      }

      traffic_weight = [
        {
          percentage      = 100
          latest_revision = true
        }
      ]

      # Optional environment variables
      # env_vars = {
      #   ENVIRONMENT = "prod"
      #   API_KEY     = "secret"
      # }

      tags = {
        Project     = "Teleios-Ecommerce"
        Environment = "Prod"
        ManagedBy   = "Terraform"
        Owner       = "TeleiosTeam"
        name        = "teleios-payment-service-app-${var.environment}"
      }
    }
  }
}
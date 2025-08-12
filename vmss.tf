# VMSS Module
module "vmss" {
  source              = "app.terraform.io/Teleios/vmss/azure"
  version             = "1.4.0"
  vmss_config         = local.merged_vmss_config
  resource_group_name = module.vnet.resource_group_name
  location            = module.vnet.location
  environment         = var.environment
  tags                = var.tags
}
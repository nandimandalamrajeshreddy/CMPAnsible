provider "azurerm" {
  features {}
}

provider "null" {  
}

module "resource-group" {
  source                    = "./modules/resource-group"
  prefix                    = var.prefix
  location                  = var.location
  #tags                      = var.tags
}

module "acr" {
  source                    = "./modules/acr"
  prefix                    = var.prefix
  rg_name                   = module.resource-group.resource_group_name
  rg_location               = module.resource-group.resource_group_location
  #tags                      = var.tags
}

module "aks-network" {
  source                    = "./modules/aks-network"
  rg_name                   = module.resource-group.resource_group_name
  rg_location               = module.resource-group.resource_group_location
  prefix                    = var.prefix
  #vnet_CIDR                 = var.vnet_CIDR
  #subnet1-CIDR              = var.subnet1-CIDR
  #subnet2-CIDR              = var.subnet2-CIDR
  #subnet3-CIDR              = var.subnet3-CIDR
  #subnet4-CIDR              = var.subnet4-CIDR
  #tags                      = var.tags
}

module "application-gateway" {
  source                    = "./modules/application-gateway"
  rg_name                   = module.resource-group.resource_group_name
  rg_location               = module.resource-group.resource_group_location
  azurerm_vnet_name         = module.aks-network.azurerm_vnet_name
  azurerm_subnet_gateway_id = module.aks-network.azurerm_subnet_gateway_id
  azurerm_public_ip_id      = module.aks-network.azurerm_public_ip_id
  prefix                    = var.prefix
  #tags                      = var.tags 
  #depends_on                = [module.aks-network.azurerm_virtual_network, module.aks-network.azurerm_public_ip, module.aks-network.azurerm_subnet]
}

module "azure-log-analytics" {
  source                    = "./modules/azure-log-analytics"
  prefix                    = var.prefix
  rg_name                   = module.resource-group.resource_group_name
  rg_location               = module.resource-group.resource_group_location
}

module "aks" {
  source                    = "./modules/aks"
  rg_name                   = module.resource-group.resource_group_name
  rg_location               = module.resource-group.resource_group_location
  prefix                    = var.prefix
  #tags                      = var.tags 
  kubernetes_version        = var.kubernetes_version
  aks_vmss_sku              = var.aks_vmss_sku
  network_policy            = var.network_policy
  aad_tenant_id             = var.aad_tenant_id
  aad_admin_group_id        = var.aad_admin_group_id
  azurerm_subnet_app_id     = module.aks-network.azurerm_subnet_app_id
  azurerm_log_analytics_id  = module.azure-log-analytics.azurerm_log_analytics_id
}

module "nodepools-agic-attachacr" {
  source                    = "./modules/nodepools-agic-attachacr"
  cluster_id                = module.aks.aks_cluster_id
  #tags                      = var.tags
  aks_vmss_sku              = var.aks_vmss_sku
  azurerm_subnet_data_id    = module.aks-network.azurerm_subnet_data_id
  azurerm_subnet_web_id     = module.aks-network.azurerm_subnet_web_id
  acr_name                  = module.acr.acr_name
  aks_cluster_name          = module.aks.aks_cluster_name
  rg_name                   = module.resource-group.resource_group_name
  rg_id                     = module.resource-group.resource_group_id
  application_gateway_network_id = module.application-gateway.application_gateway_network_id
  environment               = var.environment
}

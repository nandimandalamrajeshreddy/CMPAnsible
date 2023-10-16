data "azurerm_resource_group" "rg" {
  name                = "CMP-USEAST-RG"
}

data "azurerm_virtual_network" "vnet" {
  name                = "CF-CMP-Mor-Dev-vnet"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "sn" {
  name                = "default"
  resource_group_name = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name

}
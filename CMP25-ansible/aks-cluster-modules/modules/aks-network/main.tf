#Virtual Network with 4 tier subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = ["20.20.0.0/16"]
}

resource "azurerm_subnet" "app" {
  name                 = "app"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg_name
  address_prefixes     = ["20.20.0.0/22"]
}

resource "azurerm_subnet" "data" {
  name                 = "data"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg_name
  address_prefixes     = ["20.20.4.0/22"]
}

resource "azurerm_subnet" "web" {
  name                 = "web"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg_name
  address_prefixes     = ["20.20.8.0/22"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "gateway"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg_name
  address_prefixes     = ["20.20.12.0/22"]
}

resource "azurerm_public_ip" "publicIp" {
  name                         = "gatewayPublicIp"
  location                     = var.rg_location
  resource_group_name          = var.rg_name
  allocation_method            = "Static"
  sku                          = "Standard"
  #tags                         = var.tags
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-containers-rg"
  location = var.location
  #tags     = var.tags
}
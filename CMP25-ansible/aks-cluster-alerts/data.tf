data "azurerm_resource_group" "rg"  {
    name  = "aksrajtest-containers-rg"
}

data "azurerm_kubernetes_cluster" "aks" {
  name  = "aksrajtest-aks"
  resource_group_name = data.azurerm_resource_group.rg.name
}

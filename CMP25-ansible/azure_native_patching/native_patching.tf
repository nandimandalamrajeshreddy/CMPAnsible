data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "example" {
  name     = var.Resource_Group_Name
  location = var.location
}

resource "azurerm_automation_account" "example" {
  name                = var.Automation_Acc_Name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku_name = "Basic"


  tags = {
    environment = "development"
  }
}

resource "azurerm_log_analytics_workspace" "la_workspace" {
  name                = "${var.Log_Analytics_Name}-${var.Resource_Group_Name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  # sku                 = var.sku
  # retention_in_days   = var.retention_in_days
  tags = {
    environment = "Morpheus"
  }

}

resource "azurerm_log_analytics_linked_service" "law_link" {
  #name                = "${var.Log_Analytics_Name}-${var.Resource_Group_Name}-linked-service"
  resource_group_name = azurerm_resource_group.example.name
  workspace_name      = azurerm_log_analytics_workspace.la_workspace.name
  resource_id         = azurerm_automation_account.example.id
  linked_service_name = "automation"
}

resource "azurerm_log_analytics_solution" "law_solution_updates" {
  depends_on = [
    azurerm_log_analytics_linked_service.law_link
  ]
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  #solution_name         = var.solutions
  solution_name         = "Updates"
  workspace_resource_id = azurerm_log_analytics_workspace.la_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.la_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}

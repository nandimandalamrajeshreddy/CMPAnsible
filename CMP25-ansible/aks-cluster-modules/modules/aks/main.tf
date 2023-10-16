resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = var.rg_location
  resource_group_name = var.rg_name
  dns_prefix          = "${var.prefix}-aks"
  #tags                = var.tags
  kubernetes_version  = var.kubernetes_version
  #os_type             = var.aks_vmss_os

  default_node_pool {
    name                = "app"
    enable_auto_scaling = true
    node_count          = 1
    max_count           = 2
    min_count           = 1
    max_pods            = 75
    vm_size             = var.aks_vmss_sku
    vnet_subnet_id      = var.azurerm_subnet_app_id
    
    availability_zones  = [ "1", "2", "3" ]
  }

  network_profile {
    network_plugin = "azure"
    network_policy = var.network_policy == "0" ? "azure" : "calico"
    load_balancer_sku = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed                 = true
      tenant_id               = var.aad_tenant_id
      admin_group_object_ids  = [ var.aad_admin_group_id ]
      # V1 or legacy way of AAD connection
      # client_app_id:
      # server_app_id:
    }
  }

  addon_profile {

    aci_connector_linux {
      enabled = false
    }

    azure_policy {
      enabled = true
    }

    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = false
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.azurerm_log_analytics_id
    }
  }
}
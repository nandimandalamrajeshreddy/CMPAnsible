provider "azurerm" {
  features {}
}

resource "azurerm_monitor_action_group" "Container-EmailNotification" {
  name                = "container-actiongrp"
  resource_group_name = data.azurerm_resource_group.rg.name
  short_name          = var.short_name


# List of Email Recepients.

  email_receiver {
    name                    = "sendtoadmin"
    email_address           = var.email_address
    use_common_alert_schema = true
  }

}

# Alert for Container CPU Monitor

resource "azurerm_monitor_metric_alert" "ContainerCPUmonitor" {
  name                = "Containers CPU usage high for aks cluster CI-9"
  resource_group_name = data.azurerm_resource_group.rg.name
  scopes              = [data.azurerm_kubernetes_cluster.aks.id] 
  description         = "Action will be triggered when CPU Usage is greater than 80 for 30 minutes."


  criteria {
    metric_namespace = "Insights.Container/containers"
    metric_name      = "cpuExceededPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 95

    dimension {
      name     = "controllerName"
      operator = "Include"
      values   = ["*"]
    }
    dimension {
      name     = "Kubernetes namespace"
      operator = "Include"
      values   = ["*"]
    }
  }
  frequency = "PT1M" 
  window_size = "PT5M"
  action {
    action_group_id = azurerm_monitor_action_group.Container-EmailNotification.id
  }
}


# Alert for Container Memory High Usage

resource "azurerm_monitor_metric_alert" "ContainerMemorymonitor" {
  name                = "Containers working set memory usage high for aks cluster CI-10"
  resource_group_name = data.azurerm_resource_group.rg.name
  scopes              = [data.azurerm_kubernetes_cluster.aks.id] 
  description         = "Action will be triggered when Working Memory Usage is greater than 95 for 30 minutes."

  criteria {
    metric_namespace = "Insights.Container/containers"
    metric_name      = "memoryWorkingSetExceededPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 95

    dimension {
      name     = "controllerName"
      operator = "Include"
      values   = ["*"]
    }
    dimension {
      name     = "Kubernetes namespace"
      operator = "Include"
      values   = ["*"]
    }
  }
  frequency = "PT1M" 
  window_size = "PT5M"
  action {
    action_group_id = azurerm_monitor_action_group.Container-EmailNotification.id
  }
}

# Alert for job completed 6 hours ago

resource "azurerm_monitor_metric_alert" "jobsCompleted" {
  name                = "Jobs completed more than 6 hours ago for aks clusters CI-11"
  resource_group_name = data.azurerm_resource_group.rg.name
  scopes              = [data.azurerm_kubernetes_cluster.aks.id] 
  description         = "Action will be triggered when jobs completed is more thatn 6 hours ago"

  criteria {
    metric_namespace = "Insights.Container/pods"
    metric_name      = "completedJobsCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "controllerName"
      operator = "Include"
      values   = ["*"]
    }
    dimension {
      name     = "Kubernetes namespace"
      operator = "Include"
      values   = ["*"]
    }
  }
  frequency = "PT1M" 
  window_size = "PT1M"
  action {
    action_group_id = azurerm_monitor_action_group.Container-EmailNotification.id
  }
  
}

# Node CPU utilization is higher than 80%

resource "azurerm_monitor_metric_alert" "NodeCPUUtilization" {
  name                = "Node CPU utilization high for aks clusters CI-1"
  resource_group_name = data.azurerm_resource_group.rg.name
  scopes              = [data.azurerm_kubernetes_cluster.aks.id] 
  description         = "Action will be triggered when Node CPU Utilization is high in the cluster"

  criteria {
    metric_namespace = "Insights.Container/nodes"
    metric_name      = "cpuUsagePercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80

    dimension {
      name     = "host"
      operator = "Include"
      values   = ["*"]
    }
  }
  frequency = "PT1M" 
  window_size = "PT5M"
  action {
    action_group_id = azurerm_monitor_action_group.Container-EmailNotification.id
  }
  
}


# AKS Cluster Pod failure alerts

resource "azurerm_monitor_metric_alert" "AKSPodsfailed" {
  name                = "Pods in failed state for aks cluster CI-4"
  resource_group_name = data.azurerm_resource_group.rg.name
  scopes              = [data.azurerm_kubernetes_cluster.aks.id] 
  description         = "Action will be triggered when Pods in AKS Clusters fail"

  criteria {
    metric_namespace = "Insights.Container/pods"
    metric_name      = "podCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "phase"
      operator = "Include"
      values   = ["Failed"]
    }
  }
  frequency = "PT1M" 
  window_size = "PT5M"
  action {
    action_group_id = azurerm_monitor_action_group.Container-EmailNotification.id
  }
  
}


# Containers getting OOM Killed for AKS Cluster

resource "azurerm_monitor_metric_alert" "ContainersOOM" {
  name                = "Containers getting OOM killed for aks clusters CI-6"
  resource_group_name = data.azurerm_resource_group.rg.name
  scopes              = [data.azurerm_kubernetes_cluster.aks.id] 
  description         = "Action will be triggered when OOM killed by containers AKS Cluster"

  criteria {
    metric_namespace = "Insights.Container/pods"
    metric_name      = "oomKilledContainerCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "kubernetes namespace"
      operator = "Include"
      values   = ["*"]
    }

    dimension {
      name     = "controllerName"
      operator = "Include"
      values   = ["*"]
    }
  }
  frequency = "PT1M" 
  window_size = "PT1M"
  action {
    action_group_id = azurerm_monitor_action_group.Container-EmailNotification.id
  }
  
}


# AKS Cluster High Disk Utilization.

resource "azurerm_monitor_metric_alert" "AKSDiskUsage" {
  name                = "Disk usage high for aks clusters CI-5"
  resource_group_name = data.azurerm_resource_group.rg.name
  scopes              = [data.azurerm_kubernetes_cluster.aks.id] 
  description         = "Action will be triggered when OOM killed by containers AKS Cluster"

  criteria {
    metric_namespace = "Insights.Container/nodes"
    metric_name      = "DiskUsedPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "host"
      operator = "Include"
      values   = ["*"]
    }

    dimension {
      name     = "device"
      operator = "Include"
      values   = ["*"]
    }
  }
  frequency = "PT1M" 
  window_size = "PT5M"
  action {
    action_group_id = azurerm_monitor_action_group.Container-EmailNotification.id
  }
  
}


# Alert for Node working  Memory use is High.

resource "azurerm_monitor_metric_alert" "NodeMemoryHighUsage" {
  name                = "Node working set memory utilization high for aks clusters CI-2"
  resource_group_name = data.azurerm_resource_group.rg.name
  scopes              = [data.azurerm_kubernetes_cluster.aks.id] 
  description         = "Action will be triggered when Node memory usage is high"

  criteria {
    metric_namespace = "Insights.Container/nodes"
    metric_name      = "memoryWorkingSetPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80

    dimension {
      name     = "host"
      operator = "Include"
      values   = ["*"]
    }
  }
  frequency = "PT1M" 
  window_size = "PT5M"
  action {
    action_group_id = azurerm_monitor_action_group.Container-EmailNotification.id
  }
  
}


# Alert for Node not ready status.


resource "azurerm_monitor_metric_alert" "NodenotReady" {
  name                = "Nodes in not ready status for aks clusters CI-3"
  resource_group_name = data.azurerm_resource_group.rg.name
  scopes              = [data.azurerm_kubernetes_cluster.aks.id] 
  description         = "Action will be triggered when Node is in not ready state"

  criteria {
    metric_namespace = "Insights.Container/nodes"
    metric_name      = "nodesCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "status"
      operator = "Include"
      values   = ["Not Ready"]
    }
  }
  frequency = "PT1M" 
  window_size = "PT5M"
  action {
    action_group_id = azurerm_monitor_action_group.Container-EmailNotification.id
  }
  
}

# Alert for High persistent volumes utilization in AKS Cluster.

resource "azurerm_monitor_metric_alert" "PersistentVolHighUsage" {
  name                = "Persistent volume usage high for aks clusters CI-18"
  resource_group_name = data.azurerm_resource_group.rg.name
  scopes              = [data.azurerm_kubernetes_cluster.aks.id] 
  description         = "Action will be triggered when Node is in not ready state"

  criteria {
    metric_namespace = "Insights.Container/persistentvolumes"
    metric_name      = "pvUsageExceededPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80

    dimension {
      name     = "podName"
      operator = "Include"
      values   = ["*"]
    }

    dimension {
      name     = "kubernetesNamespace"
      operator = "Include"
      values   = ["*"]
    }

  }
  frequency = "PT1M" 
  window_size = "PT5M"
  action {
    action_group_id = azurerm_monitor_action_group.Container-EmailNotification.id
  }
  
}


resource "azurerm_policy_definition" "policy-definition" {
  name         = "${var.Automation_Acc_Name}-policy-assignment"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "${var.Automation_Acc_Name}-policy-assignment"
  description  = "This policy checks for patch management"


  policy_rule = <<POLICY_RULE
  {
    "if": {
      "allOf": [
        {
          "field": "type",
          "equals": "Microsoft.Compute/virtualMachines"
        },
        {
          "field": "[concat('tags[', parameters('CMP_PATCH'), ']')]",
          "equals": "[parameters('Status')]"
        },
        {
          "anyOf": [
            {
              "field": "Microsoft.Compute/imageId",
              "in": "[parameters('listOfImageIdToInclude')]"
            },
            {
              "allOf": [
                {
                  "field": "Microsoft.Compute/imagePublisher",
                  "equals": "RedHat"
                },
                {
                  "field": "Microsoft.Compute/imageOffer",
                  "in": [
                    "RHEL",
                    "RHEL-SAP-HANA"
                  ]
                },
                {
                  "anyOf": [
                    {
                      "field": "Microsoft.Compute/imageSKU",
                      "like": "6.*"
                    },
                    {
                      "field": "Microsoft.Compute/imageSKU",
                      "like": "7*"
                    },
                    {
                      "field": "Microsoft.Compute/imageSKU",
                      "like": "8*"
                    }
                  ]
                }
              ]
            },
            {
              "allOf": [
                {
                  "field": "Microsoft.Compute/imagePublisher",
                  "equals": "SUSE"
                },
                {
                  "field": "Microsoft.Compute/imageOffer",
                  "in": [
                    "SLES",
                    "SLES-HPC",
                    "SLES-HPC-Priority",
                    "SLES-SAP",
                    "SLES-SAP-BYOS",
                    "SLES-Priority",
                    "SLES-BYOS",
                    "SLES-SAPCAL",
                    "SLES-Standard"
                  ]
                },
                {
                  "anyOf": [
                    {
                      "field": "Microsoft.Compute/imageSKU",
                      "like": "12*"
                    }
                  ]
                }
              ]
            },
            {
              "allOf": [
                {
                  "field": "Microsoft.Compute/imagePublisher",
                  "equals": "Canonical"
                },
                {
                  "field": "Microsoft.Compute/imageOffer",
                  "equals": "UbuntuServer"
                },
                {
                  "anyOf": [
                    {
                      "field": "Microsoft.Compute/imageSKU",
                      "like": "14.04*LTS"
                    },
                    {
                      "field": "Microsoft.Compute/imageSKU",
                      "like": "16.04*LTS"
                    },
                    {
                      "field": "Microsoft.Compute/imageSKU",
                      "like": "18.04*LTS"
                    }
                  ]
                }
              ]
            },
            {
              "allOf": [
                {
                  "field": "Microsoft.Compute/imagePublisher",
                  "equals": "Oracle"
                },
                {
                  "field": "Microsoft.Compute/imageOffer",
                  "equals": "Oracle-Linux"
                },
                {
                  "anyOf": [
                    {
                      "field": "Microsoft.Compute/imageSKU",
                      "like": "6.*"
                    },
                    {
                      "field": "Microsoft.Compute/imageSKU",
                      "like": "7.*"
                    },
                    {
                      "field": "Microsoft.Compute/imageSKU",
                      "like": "8.*"
                    }
                  ]
                }
              ]
            },
            {
              "allOf": [
                {
                  "field": "Microsoft.Compute/imagePublisher",
                  "equals": "OpenLogic"
                },
                {
                  "field": "Microsoft.Compute/imageOffer",
                  "in": [
                    "CentOS",
                    "Centos-LVM",
                    "CentOS-SRIOV",
                    "CentOS-CI"
                  ]
                },
                {
                  "anyOf": [
                    {
                      "field": "Microsoft.Compute/imageSKU",
                      "like": "6.*"
                    },
                    {
                      "field": "Microsoft.Compute/imageSKU",
                      "like": "7*"
                    }
                  ]
                }
              ]
            },
            {
              "allOf": [
                {
                  "field": "Microsoft.Compute/imagePublisher",
                  "equals": "cloudera"
                },
                {
                  "field": "Microsoft.Compute/imageOffer",
                  "equals": "cloudera-centos-os"
                },
                {
                  "field": "Microsoft.Compute/imageSKU",
                  "like": "7*"
                }
              ]
            }
          ]
        }
      ]
    },
    "then": {
      "effect": "deployIfNotExists",
      "details": {
        "type": "Microsoft.Compute/virtualMachines/extensions",
        "roleDefinitionIds": [
          "/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293"
        ],
        "existenceCondition": {
          "allOf": [
            {
              "field": "Microsoft.Compute/virtualMachines/extensions/type",
              "equals": "OmsAgentForLinux"
            },
            {
              "field": "Microsoft.Compute/virtualMachines/extensions/publisher",
              "equals": "Microsoft.EnterpriseCloud.Monitoring"
            },
            {
              "field": "Microsoft.Compute/virtualMachines/extensions/provisioningState",
              "equals": "Succeeded"
            }
          ]
        },
        "deployment": {
          "properties": {
            "mode": "incremental",
            "template": {
              "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
              "contentVersion": "1.0.0.0",
              "parameters": {
                "vmName": {
                  "type": "string"
                },
                "location": {
                  "type": "string"
                },
                "logAnalytics": {
                  "type": "string"
                }
              },
              "variables": {
                "vmExtensionName": "MMAExtension",
                "vmExtensionPublisher": "Microsoft.EnterpriseCloud.Monitoring",
                "vmExtensionType": "OmsAgentForLinux",
                "vmExtensionTypeHandlerVersion": "1.7"
              },
              "resources": [
                {
                  "name": "[concat(parameters('vmName'), '/', variables('vmExtensionName'))]",
                  "type": "Microsoft.Compute/virtualMachines/extensions",
                  "location": "[parameters('location')]",
                  "apiVersion": "2018-06-01",
                  "properties": {
                    "publisher": "[variables('vmExtensionPublisher')]",
                    "type": "[variables('vmExtensionType')]",
                    "typeHandlerVersion": "[variables('vmExtensionTypeHandlerVersion')]",
                    "autoUpgradeMinorVersion": true,
                    "settings": {
                      "workspaceId": "[reference(parameters('logAnalytics'), '2015-03-20').customerId]",
                      "stopOnMultipleConnections": "true"
                    },
                    "protectedSettings": {
                      "workspaceKey": "[listKeys(parameters('logAnalytics'), '2015-03-20').primarySharedKey]"
                    }
                  }
                }
              ],
              "outputs": {
                "policy": {
                  "type": "string",
                  "value": "[concat('Enabled extension for VM', ': ', parameters('vmName'))]"
                }
              }
            },
            "parameters": {
              "vmName": {
                "value": "[field('name')]"
              },
              "location": {
                "value": "[field('location')]"
              },
              "logAnalytics": {
                "value": "[parameters('logAnalytics')]"
              }
            }
          }
        }
      }
    }
  }
POLICY_RULE


  parameters = <<PARAMETERS
    {
      "logAnalytics": {
        "type": "String",
        "metadata": {
          "displayName": "Log Analytics workspace",
          "description": "Select Log Analytics workspace from dropdown list. If this workspace is outside of the scope of the assignment you must manually grant 'Log Analytics Contributor' permissions (or similar) to the policy assignment's principal ID.",
          "strongType": "omsWorkspace",
          "assignPermissions": true
        }
      },
      "listOfImageIdToInclude": {
        "type": "Array",
        "metadata": {
          "displayName": "Optional: List of VM images that have supported Linux OS to add to scope",
          "description": "Example value: '/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage'"
        },
        "defaultValue": []
      },
      "CMP_PATCH": {
        "type": "String",
        "metadata": {
          "displayName": "CMP_PATCH",
          "description": "CMP_PATCH"
        }
      },
      "Status": {
        "type": "String",
        "metadata": {
          "displayName": "Patching value  ProductionLinux",
          "description": "Patching value  ProductionLinux"
        }
      }
    }
PARAMETERS

}

resource "azurerm_policy_assignment" "policy-assignment" {
  name                 = "${var.Automation_Acc_Name}-policy-assignment"
  #scope                = azurerm_resource_group.example.id
  scope                = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.policy-definition.id
  description          = "Policy Assignment created via terraform script"
  display_name         = "${var.Automation_Acc_Name}-policy-assignment"
  #location             = "westeurope"

  parameters = <<PARAMETERS
{
  "CMP_PATCH": {
    "value": "CMP_PATCH"
  },
  "Status": {
  "value": "ProductionLinux"
  },
  "logAnalytics": {
  "value": "${azurerm_log_analytics_workspace.la_workspace.id}"
  }
}
PARAMETERS
location=var.location

identity {
type="SystemAssigned"
}
}

resource "azurerm_policy_remediation" "policy-remediation" {
  name                 = "${var.Automation_Acc_Name}-policy-remediation"
  scope                = azurerm_policy_assignment.policy-assignment.scope
  policy_assignment_id = azurerm_policy_assignment.policy-assignment.id
 # location_filters     = ["West Europe"]
}
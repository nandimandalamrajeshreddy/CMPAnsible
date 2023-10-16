variable "Resource_Group_Name" {
    type = string
    description = "The name of the resource group to deploy the log analytics workspace in to."
}

variable "location" {
   type = string
   description = "The location to deploy the resources like East US"
  # default = 
}

variable "Log_Analytics_Name" {
    type = string
    description = "The name of the log analytics workspace like my-log-analytics"
    #default = "my-log-analytics"
}
variable "Automation_Acc_Name" {
    type = string
    description = "The name of the Automation_Acc_Name like my-automation-account"
  #  default = "my-automation-account"
}

# variable "sku" {
#     type = string
#     description = "The sku for the log analytics workspace."
#     default = "PerGB2018"
# }

# variable "retention_in_days" {
#     type = number
#     description = "The retention period for data stored in the Log Analytics Workspace"
#     default = 30
# }

# variable "solutions" {
#     type = string
#     description = "Solution name to be installed in to the log analytics workspace"
#     default = "Updates"
# }

# variable "solutions" {
#     type = list(object({ name = string, publisher = string, product = string }))
#     description = "Solutions to install in to the log analytics workspace."
#     default = []
# }

# variable "tags" {
#     type = map(string)
#     description = "Tags to apply to the log analytics workspace and solutions."
#     default = {}
# }


# variable "azure_policy_definition_name" {
#    type = string
#    description = "azure policy definition name"
#    default = "morpheus-policy"
# }
# variable "azurerm_policy_remediation_name" {
#    type = string
#    description = "azure policy remediation name"
#    default = "morpheus-remidiation"
# }
variable "subscription_id"  {
    description  =  "Variables for Storage accounts"
    type         =  string
}

variable "client_id"  {
    description  =  "Variables for Storage accounts"
    type         =  string
}

variable "client_secret"  {
    description  =  "Variables for Storage accounts"
    type         =  string
}
variable "tenant_id"  {
    description  =  "Variables for Storage accounts"
    type         =  string
}
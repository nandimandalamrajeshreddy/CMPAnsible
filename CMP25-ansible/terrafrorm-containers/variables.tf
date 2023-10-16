variable "prefix" {
  description = "A prefix used for all resources in this AKS"
}

variable "location" {
  description = "The Azure Region in which all resources in this AKS should be provisioned[needs zone support]: eastus2, eastus, centralus"
}

variable "acr_name" {
  description = "Name for ACR to be created (Must be globally unique)"
}

variable "aad_admin_group_id" {
  description = "AAD admin group which will be added as admin privileged user for AKS"
}

variable "aad_tenant_id" {
  description = "Tenant ID of AAD owner cloud account"
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of Log analytics workspace"
}

variable "app_gateway_name" {
  description = "Name of the Application Gateway."
  default     = "AppGateway"
}

variable "app_gateway_sku" {
  description = "Name and tier of the Application Gateway v2 SKU:  'Standard_v2' or 'WAF_v2'"
  default     = "WAF_v2"
}

variable "aks_vmss_sku" {
  description = "SKU for AKS Virtual Machine Scale Sets. Default is 'Standard_DS2_v2'."
  default     = "Standard_DS2_v2"
}

# Edit the tags below before running terraform
variable "tags" {
  type = map(string)

  default = {
    source = "terraform"
    organization = "Unisys"
    project = "CMP"
    creator = "rama.akundi@unisys.com"
  }
}

# New Vriables added for accepting subscription, tenant, client id and client secret
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
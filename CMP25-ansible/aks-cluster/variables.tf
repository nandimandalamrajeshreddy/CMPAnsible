#############################################################################################################################
## Edit the tags below before running terraform
variable "tags" {
  type = map(string)

  default = {
    source = "terraform"
    organization = "enter-organization"
    project = "enter-project"
    creator = "enter-mail-id-of-creator"
  }
}

################################################## DO NOT CHANGE ANYTHING BELOW ###############################################
variable "prefix" {
  description = "A prefix used for all resources in this AKS"
}

variable "aksclustername" {
  description = " Existing AKS Cluster name for monitoring"
}

#variable "email_address" {
#  description = "Email Address"
#  type  = string
#}

#variable "Environment" {
#  description = "Environment Details"
#  type  = string
#  default = "prd"
#}

#variable "short_name" {
#  description = "Email Address"
#  type  = string
#  default = "cmpaction"
#}



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

variable "app_gateway_name" {
  description = "Name of the Application Gateway."
  default     = "AppGatewayterra"
}

variable "app_gateway_sku" {
  description = "Name and tier of the Application Gateway v2 SKU:  'Standard_v2' or 'WAF_v2'"
  default     = "WAF_v2"
}

variable "waf_enabled" {
  description = "Set to true to enable WAF on Application Gateway."
  type        = bool
  default     = true
}

variable "waf_configuration" {
  description = "Configuration block for WAF."
  type = object({
    firewall_mode            = string,
    rule_set_type            = string,
    rule_set_version         = string,
    file_upload_limit_mb     = number,
    max_request_body_size_kb = number,
  })
  default = null
}


variable "aks_vmss_sku" {
  description = "SKU for AKS Virtual Machine Scale Sets. Default is 'Standard_DS2_v2'."
  default     = "Standard_DS2_v2"
}

variable "kubernetes_version" {
  description = "kubernetes version"
  default     = "1.20.7"
}

variable "network_policy" {
  description = "Enter 0 or 1 as per the requirement [ 0 for Azure Network Policy, 1 for Calico Network Policy]"
  default     = "0"
#  validation {
#    condition     = var.network_policy == "0" || var.network_policy == "1"
#    error_message = "Sorry you entered invalid choice."
#  }
}
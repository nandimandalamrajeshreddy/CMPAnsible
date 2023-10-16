#provide organisation,project,creator user email id values

#variable "tags" {
#  type = map(string)
#
#  default = {
#    source = "terraform"
#    organization = "unisys"
#    project = "cf-containers"
#    creator = "useremail@abc.com"
#  }
#}

variable "prefix" {
  description = "A prefix used for all resources in this AKS"
  default = "akscluster104"
}

variable "location" {
  description = "The Azure Region in which all resources in this AKS should be provisioned[needs zone support]: eastus2, eastus, centralus"
  default = "eastus2"
}

variable "aad_admin_group_id" {
  description = "AAD admin group which will be added as admin privileged user for AKS"
}

variable "aad_tenant_id" {
  description = "Tenant ID of AAD owner cloud account"
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
  description = "Enter 0 or 1 as per the choice:- [ 0 for Azure Network Policy, 1 for Calico Network Policy]"
  default    = "1"
}

variable "environment" {
  description = "Enter 0 or 1 as per the choice:- [ 0 if running in Linux environment, 1 if running in Windows environment]"
}

/*

variable "vnet_CIDR" {
  type = string
  description = "Enter CIDR for VNET"
  #default = "10.1.0.0/16"
}

variable "subnet1-CIDR" {
  type = string
  description = "Enter subnet1 CIDR"
  #default = "10.1.0.0/22"
}

variable "subnet2-CIDR" {
  type = string
  description = "Enter subnet2 CIDR"
  #default = "10.1.4.0/22"
}

variable "subnet3-CIDR" {
  type = string
  description = "Enter subnet3 CIDR"
  #default = "10.1.8.0/22"
}

variable "subnet4-CIDR" {
  type = string
  description = "Enter subnet4 CIDR"
  #default = "10.1.12.0/22"
}
*/

tags = {

    source = "AKS terraform template"
    organization = "enter-organisation-name"
    project = "enter-project-name"
    creator = "enter-user-email"
}

prefix = "enter a string used as prefix for naming of all the resources. note string should be alphanumeric only with length of 5 to 50."

location = "enter a Azure Region in which all resources will be provisioned[needs zone support] like:- eastus2, eastus, centralus"

aad_admin_group_id = "enter AAD admin group id which will be added as admin privileged user for AKS"

aad_tenant_id = "enter Tenant ID of AAD owner cloud account"

aks_vmss_sku = "enter SKU for AKS Virtual Machine Scale Sets. Default is Standard_DS2_v2 (2GB RAM) "

kubernetes_version = "enter kubernetes version, like:- 1.20.7"

#replace x and y

vnet_CIDR    = ["x.x.x.x/y"]

subnet1-CIDR = ["x.x.x.x/y"]

subnet2-CIDR = ["x.x.x.x/y"]

subnet3-CIDR = ["x.x.x.x/y"]

subnet4-CIDR = ["x.x.x.x/y"]

######################################################################################
# uncommnet "network_policy" variable below, do not uncomment both.
# 0 for Azure network policy and 1 for Calico network policy

#network_policy = "0"
#network_policy = "1"
######################################################################################


######################################################################################
# uncommnet "environment" variable below, do not uncomment both.
# 0 if running in Linux environment, 1 if running in Windows environment

#environment = "0"
#environment = "1"
######################################################################################

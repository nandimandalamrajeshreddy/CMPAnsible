Please make sure that the region where you deploy this terraform has following:
 - 3 availability zones
 - Supports preview features mentioned in prerequisite/machine setup section 
 - VMSS CPU remaining quota 18+

Sections to follow:
 - Accelerators Landing zone setup (required for creating log analytics workspace integration) Else setup a workspace manually.
 - Section 2 for setup
 - Section 3.3.1 subsection Terraform >  cd path mentioned in guide is the directory "aks-agic" here.
 - In variables.tf file, edit the tags before running terraform apply.

Inputs required: Details can be seen during installation as well, listed here so that you can prepare in advance.
 - prefix: can be any alphanumeric name e.g. abc, unisys, cmp. No hyphens needed
 - location: eastus2, eastus, centralus - these were initially supported locations. Azure keeps adding features to new locations, recommended is to get latest list of supported locations where features are supported.
 - acr_name:  Must be globally Unique
 - aad_admin_group_id: AAD admin group which will be added as admin privileged user for AKS. Get group ID from Azure.
 - aad_tenant_id: Tenant ID of AAD owner cloud account. Can get it from command "az account show"
 - log_analytics_workspace_id: ID of Log Analytics Workspace to forward logs from cluster to Azure monitoring.

Regards!
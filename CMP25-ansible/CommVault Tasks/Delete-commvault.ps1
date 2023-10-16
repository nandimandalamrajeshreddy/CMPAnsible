$isCommVault = "<%=customOptions.CMP_BACKUP%>"
if ($isCommVault -ne "COMMVAULT") 
{ 
 	Write-Output "Commvault Backup not enabled"
	exit 0
}
$nameValue = "<%=instance.name%>"
$cloudType = "<%=zone.cloudTypeCode%>"
if ($cloudType -eq "azure") 
{
	C:\CMP-Scripts\cv_DeleteVMFromSubclient.ps1 -inputstring "cmp_param_vm1_ritm=12348;cmp_param_vm1_retry_count=0;cmp_param_vm1_get_cached_data=0;cmp_param_vm1='$nameValue';cmp_param_vm1_operation=add-vm-to-subclient;cmp_param_vm1_os=windows;cmp_param_vm1_commvault_server=10.1.0.15;cmp_param_vm1_client_name=AZ_CMP;cmp_param_vm1_instance_name=Azure Resource Manager;cmp_param_vm1_subclient_name=snapshot_AZ_CMP;cmp_param_vm1_commvault_user_cred_token=YWRtaW4=&&VW5pc3lzKjEyMzQ1&&5f932726af854a6ea472be1de1466075ccb6ae056b907f401acedf81e6f8c4f5"
}
elseif($cloudType -eq "amazon")
{
	C:\CMP-Scripts\test_cv_DeleteVMFromSubclient.ps1 -inputstring "cmp_param_vm1_ritm=12348;cmp_param_vm1_retry_count=0;cmp_param_vm1_get_cached_data=0;cmp_param_vm1='$nameValue';cmp_param_vm1_operation=add-vm-to-subclient;cmp_param_vm1_os=windows;cmp_param_vm1_commvault_server=10.1.0.15;cmp_param_vm1_client_name=Amazon;cmp_param_vm1_instance_name=Amazon;cmp_param_vm1_subclient_name=Snapshot_AWS_CMP;cmp_param_vm1_commvault_user_cred_token=YWRtaW4=&&VW5pc3lzKjEyMzQ1&&5f932726af854a6ea472be1de1466075ccb6ae056b907f401acedf81e6f8c4f5"
}
elseif($cloudType -eq "googlecloud")
{
	C:\CMP-Scripts\gcp_cv_DeleteVMFromSubclient.ps1 -inputstring "cmp_param_vm1_ritm=12348;cmp_param_vm1_retry_count=0;cmp_param_vm1_get_cached_data=0;cmp_param_vm1='$nameValue';cmp_param_vm1_operation=add-vm-to-subclient;cmp_param_vm1_os=windows;cmp_param_vm1_commvault_server=10.1.0.15;cmp_param_vm1_client_name=GCP_Hyper_CMP;cmp_param_vm1_instance_name=Google;cmp_param_vm1_subclient_name=Snapshot_GCP_CMP;cmp_param_vm1_commvault_user_cred_token=YWRtaW4=&&VW5pc3lzKjEyMzQ1&&5f932726af854a6ea472be1de1466075ccb6ae056b907f401acedf81e6f8c4f5"
}
else 
{
	Write-Output "Not supported Cloud type"
}

sleep 10
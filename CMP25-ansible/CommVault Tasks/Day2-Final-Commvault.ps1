$cloudType = "<%=zone.cloudTypeCode%>"
$nameValue = "<%=instance.name%>"

echo $cloudType
if ($cloudType -eq "azure")
{
    $backup_option_enable = "<%=customOptions.CMP_BACKUP_31E%>"
	$backup_option_disable = "<%=customOptions.CMP_BACKUP_31D%>"
    $COMMVAULTE = "COMMVAULT"
    $COMMVAULTD = "RETAIN"	

    if ($backup_option_enable -eq $COMMVAULTE)
    {
        C:\CMP-Scripts\cv_AddVMToSbuclient.ps1 -inputstring "cmp_param_vm1_ritm=12348;cmp_param_vm1_retry_count=0;cmp_param_vm1_get_cached_data=0;cmp_param_vm1='$nameValue';cmp_param_vm1_operation=add-vm-to-subclient;cmp_param_vm1_os=windows;cmp_param_vm1_commvault_server=10.1.0.15;cmp_param_vm1_client_name=AZ_CMP;cmp_param_vm1_instance_name=Azure Resource Manager;cmp_param_vm1_subclient_name=snapshot_AZ_CMP;cmp_param_vm1_commvault_user_cred_token=YWRtaW4=&&VW5pc3lzKjEyMzQ1&&5f932726af854a6ea472be1de1466075ccb6ae056b907f401acedf81e6f8c4f5"
        Write-Output "Azure-BACKUP SCHEDULED"
    }
    elseif ($backup_option_disable -eq $COMMVAULTD)
    {
        C:\CMP-Scripts\cv_DeleteVMFromSubclient.ps1 -inputstring "cmp_param_vm1_ritm=12348;cmp_param_vm1_retry_count=0;cmp_param_vm1_get_cached_data=0;cmp_param_vm1='$nameValue';cmp_param_vm1_operation=add-vm-to-subclient;cmp_param_vm1_os=windows;cmp_param_vm1_commvault_server=10.1.0.15;cmp_param_vm1_client_name=AZ_CMP;cmp_param_vm1_instance_name=Azure Resource Manager;cmp_param_vm1_subclient_name=snapshot_AZ_CMP;cmp_param_vm1_commvault_user_cred_token=YWRtaW4=&&VW5pc3lzKjEyMzQ1&&5f932726af854a6ea472be1de1466075ccb6ae056b907f401acedf81e6f8c4f5"
        Write-Output "Azure-BACKUP DISABLED"
    }
    else 
    {
        Write-Output "This is not an instance with Azure-COMMVAULT BACKUP option...."
    }
}

elseif ($cloudType -eq "amazon")
{
    $backup_option_enable = "<%=customOptions.CMP_BACKUP_31E%>"
	$backup_option_disable = "<%=customOptions.CMP_BACKUP_31D%>"
    $COMMVAULTE = "COMMVAULT"
    $COMMVAULTD = "RETAIN"

    if ($backup_option_enable -eq $COMMVAULTE)
    {
        C:\CMP-Scripts\test_cv_AddVMToSbuclient.ps1 -inputstring "cmp_param_vm1_ritm=12348;cmp_param_vm1_retry_count=0;cmp_param_vm1_get_cached_data=0;cmp_param_vm1='$nameValue';cmp_param_vm1_operation=add-vm-to-subclient;cmp_param_vm1_os=windows;cmp_param_vm1_commvault_server=10.1.0.15;cmp_param_vm1_client_name=Amazon;cmp_param_vm1_instance_name=Amazon;cmp_param_vm1_subclient_name=Snapshot_AWS_CMP;cmp_param_vm1_commvault_user_cred_token=YWRtaW4=&&VW5pc3lzKjEyMzQ1&&5f932726af854a6ea472be1de1466075ccb6ae056b907f401acedf81e6f8c4f5"
        Write-Output "AWS-COMMVAULT BACKUP SCHEDULED"
    }
    elseif ($backup_option_disable -eq $COMMVAULTD)
    {
        C:\CMP-Scripts\test_cv_DeleteVMFromSubclient.ps1 -inputstring "cmp_param_vm1_ritm=12348;cmp_param_vm1_retry_count=0;cmp_param_vm1_get_cached_data=0;cmp_param_vm1='$nameValue';cmp_param_vm1_operation=add-vm-to-subclient;cmp_param_vm1_os=windows;cmp_param_vm1_commvault_server=10.1.0.15;cmp_param_vm1_client_name=Amazon;cmp_param_vm1_instance_name=Amazon;cmp_param_vm1_subclient_name=Snapshot_AWS_CMP;cmp_param_vm1_commvault_user_cred_token=YWRtaW4=&&VW5pc3lzKjEyMzQ1&&5f932726af854a6ea472be1de1466075ccb6ae056b907f401acedf81e6f8c4f5"
        Write-Output "AWS-COMMVAULT BACKUP DISABLED"
    }
    else 
    {
        Write-Output "This is not an instance with AWS-COMMVAULT BACKUP option...."
    }
}

elseif ($cloudType -eq "googlecloud")
{
    $backup_option_enable = "<%=customOptions.CMP_BACKUP_31E%>"
	$backup_option_disable = "<%=customOptions.CMP_BACKUP_31D%>"
    $COMMVAULTE = "COMMVAULT"
    $COMMVAULTD = "RETAIN"	


    if ($backup_option_enable -eq $COMMVAULTE)
    {
        C:\CMP-Scripts\gcp_cv_AddVMToSbuclient.ps1 -inputstring "cmp_param_vm1_ritm=12348;cmp_param_vm1_retry_count=0;cmp_param_vm1_get_cached_data=0;cmp_param_vm1='$nameValue';cmp_param_vm1_operation=add-vm-to-subclient;cmp_param_vm1_os=windows;cmp_param_vm1_commvault_server=10.1.0.15;cmp_param_vm1_client_name=GCP_Hyper_CMP;cmp_param_vm1_instance_name=Google;cmp_param_vm1_subclient_name=Snapshot_GCP_CMP;cmp_param_vm1_commvault_user_cred_token=YWRtaW4=&&VW5pc3lzKjEyMzQ1&&5f932726af854a6ea472be1de1466075ccb6ae056b907f401acedf81e6f8c4f5"
        Write-Output "GCP-COMMVAULT BACKUP SCHEDULED"
    }
    elseif ($backup_option_disable -eq $COMMVAULTD)
    {
        C:\CMP-Scripts\gcp_cv_DeleteVMFromSubclient.ps1 -inputstring "cmp_param_vm1_ritm=12348;cmp_param_vm1_retry_count=0;cmp_param_vm1_get_cached_data=0;cmp_param_vm1='$nameValue';cmp_param_vm1_operation=add-vm-to-subclient;cmp_param_vm1_os=windows;cmp_param_vm1_commvault_server=10.1.0.15;cmp_param_vm1_client_name=GCP_Hyper_CMP;cmp_param_vm1_instance_name=Google;cmp_param_vm1_subclient_name=Snapshot_GCP_CMP;cmp_param_vm1_commvault_user_cred_token=YWRtaW4=&&VW5pc3lzKjEyMzQ1&&5f932726af854a6ea472be1de1466075ccb6ae056b907f401acedf81e6f8c4f5"
        Write-Output "GCP-COMMVAULT BACKUP DISABLED"
    }
    else 
    {
        Write-Output "This is not an instance with GCP-COMMVAULT BACKUP option...."
    }
}

else
{
	    Write-Output "Not Supported Cloud Type"
}
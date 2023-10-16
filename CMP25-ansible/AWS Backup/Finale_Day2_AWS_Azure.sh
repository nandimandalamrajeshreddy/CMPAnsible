#!/bin/bash
username=<%=cypher.read('secret/spnusername')%>
password=<%=cypher.read('secret/spnpassword')%>
tenent=<%=cypher.read('secret/spntenent')%>
rcv=<%=cypher.read('secret/recovaryvault')%>
subscriptionId=<%=cypher.read('secret/subscriptionId')%>
enable="<%=customOptions.CMP_BACKUP_31E%>"
disable="<%=customOptions.CMP_BACKUP_31D%>"
cloudtype=<%=zone.cloudTypeCode%>


if [ "$cloudtype" == "azure" ]
then
    vm=<%=instance.name%>
	az login --service-principal --username $username --password $password --tenant $tenent
	
	vmVal="/$vm/p"
	rg=$(az resource list | sed -n $vmVal | head -1 | grep -Po 'resourceGroups/\K.*(?=/providers)') 
    echo -e "$(date "+%m%d%Y %T") : Backup related activity for $vm Instance....."
	echo -e $enable
	echo -e $disable
	if [ "$enable"  == "CNB-DAILY-RESUME" ]
	then
		echo "Resuming daily backup for $vm started...."
		az tag update --resource-id /subscriptions/$subscriptionId/resourcegroups/$rg/providers/Microsoft.Compute/virtualMachines/$vm --operation merge --tags CMP_BACKUP=CNB-DAILY
		az backup protection resume --container-name $vm --policy-name DefaultPolicy --item-name $vm --resource-group $rg --vault-name $rcv --backup-management-type AzureIaasVM
		#echo "DAILY Backup of AZURE Instance $vm has been resumed"	
	elif [ "$enable"  == "CNB-WEEKLY-RESUME" ]
	then
		echo "Resuming weekly backup for $vm started...."
		az tag update --resource-id /subscriptions/$subscriptionId/resourcegroups/$rg/providers/Microsoft.Compute/virtualMachines/$vm --operation merge --tags CMP_BACKUP=CNB-WEEKLY
		az backup protection resume --container-name $vm --policy-name CMPWeekly --item-name $vm --resource-group $rg --vault-name $rcv --backup-management-type AzureIaasVM
		#echo "WEEKLY Backup of AZURE Instance $vm has been resumed"
	elif [ "$enable"  == "CNB-DAILY" ]
	then
		echo "Enabling daily backup for $vm started...."
		az tag update --resource-id /subscriptions/$subscriptionId/resourcegroups/$rg/providers/Microsoft.Compute/virtualMachines/$vm --operation merge --tags CMP_BACKUP=CNB-DAILY
		az backup protection enable-for-vm --resource-group $rg --vault-name $rcv --vm $vm --policy-name DefaultPolicy
		#echo "DAILY Backup of AZURE Instance $vm has been Enabled"
	elif [ "$enable"  == "CNB-WEEKLY" ]
	then
		echo "Enabling weekly backup for $vm started...."
		az tag update --resource-id /subscriptions/$subscriptionId/resourcegroups/$rg/providers/Microsoft.Compute/virtualMachines/$vm --operation merge --tags CMP_BACKUP=CNB-WEEKLY
		az backup protection enable-for-vm --resource-group $rg --vault-name $rcv --vm $vm --policy-name CMPWeekly
		#echo "WEEKLY Backup of AZURE Instance $vm has been Enabled"
	elif [ "$disable"  == "RETAIN" ]
	then
		echo "Disabling and retaining  backup for $vm started...."
		az tag update --resource-id /subscriptions/$subscriptionId/resourcegroups/$rg/providers/Microsoft.Compute/virtualMachines/$vm --operation merge --tags CMP_BACKUP=DISABLED-RETAINED
		az backup protection disable --resource-group $rg --vault-name $rcv --backup-management-type AzureIaasVM --container-name $vm --item-name $vm --delete-backup-data false --yes
		#echo "Backup of AZURE Instance $vm has been Disabled and Backup is retained"
	elif [ "$disable"  == "DELETE" ]
	then
		echo "Disabling and deleting  backup for $vm started...."
		az tag update --resource-id /subscriptions/$subscriptionId/resourcegroups/$rg/providers/Microsoft.Compute/virtualMachines/$vm --operation merge --tags CMP_BACKUP=DISABLED-DELETED
		az backup protection disable --resource-group $rg --vault-name $rcv --backup-management-type AzureIaasVM --container-name $vm --item-name $vm --delete-backup-data true --yes
		#echo "Backup of AZURE Instance $vm has been Disabled and Backup is Deleted"
	elif [ "$enable"  == "COMMVAULT" ]
	then
		az tag update --resource-id /subscriptions/$subscriptionId/resourcegroups/$rg/providers/Microsoft.Compute/virtualMachines/$vm --operation merge --tags CMP_BACKUP=COMMVAULT
		echo "COMMVAULT Backup of AZURE Instance $vm has been enabled"
	else
		-e "$(date "+%m%d%Y %T") : $vm is not enabled with Cloud Native Backup"
	fi
	az logout

elif [ "$cloudtype" == "amazon" ]
then
    instanceName=<%=instance.name%>
    instanceid=<%=server.externalId%>
    if [ "$enable"  == "CNB-DAILY-RESUME" ]
	then
        echo -e "$(date "+%m%d%Y %T") : Resuming Daily Backup"
        aws ec2 create-tags --resources $instanceid --tags Key=CMP_BACKUP,Value=CNB-DAILY
        echo -e "$(date "+%m%d%Y %T") : Daily Backups have been Resumed"
    
    elif [ "$enable"  == "CNB-WEEKLY-RESUME" ]
	then
        echo -e "$(date "+%m%d%Y %T") : Resuming Weekly Backup"
        aws ec2 create-tags --resources $instanceid --tags Key=CMP_BACKUP,Value=CNB-WEEKLY
        echo -e "$(date "+%m%d%Y %T") : Weekly Backups have been Resumed"

	elif [ "$enable"  == "CNB-DAILY" ]
	then
        echo -e "$(date "+%m%d%Y %T") : Enabling Daily Backup"
        aws ec2 create-tags --resources $instanceid --tags Key=CMP_BACKUP,Value=CNB-DAILY
        echo -e "$(date "+%m%d%Y %T") : Daily Backups have been Enabled"

	elif [ "$enable"  == "CNB-WEEKLY" ]
	then
        echo -e "$(date "+%m%d%Y %T") : Enabling Weekly Backup"
        aws ec2 create-tags --resources $instanceid --tags Key=CMP_BACKUP,Value=CNB-WEEKLY
        echo -e "$(date "+%m%d%Y %T") : Weekly Backups have been Enabled"

	elif [ "$enable"  == "COMMVAULT" ]
	then
        echo -e "$(date "+%m%d%Y %T") : Enabling CommVault Backup"
        aws ec2 create-tags --resources $instanceid --tags Key=CMP_BACKUP,Value=COMMVAULT
        echo -e "$(date "+%m%d%Y %T") : CommVault Backups have been Enabled"


	elif [ "$disable"  == "RETAIN" ]
	then
        isCloudNativeBackup=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instanceid"  --query 'Tags[?Key==`CMP_BACKUP`].Value' --output text)
            if [[ "$isCloudNativeBackup"  == "CNB-DAILY" ||  "$isCloudNativeBackup"  == "CNB-WEEKLY" ||  "$isCloudNativeBackup"  == "COMMVAULT" ]]
            then
                echo -e "$(date "+%m%d%Y %T") : Disabling Backup"
                aws ec2 delete-tags --resources $instanceid --tags Key=CMP_BACKUP
                echo -e "$(date "+%m%d%Y %T") : Backups have been Disabled"
            else
                echo -e "$(date "+%m%d%Y %T") : Its not AWS Machine with Cloud Native Backup Enabled"
            fi

	elif [ "$disable"  == "DELETE" ]
	then
        isCloudNativeBackup_Mor="<%=customOptions.CMP_BACKUP%>"
        isCloudNativeBackup=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instanceid"  --query 'Tags[?Key==`CMP_BACKUP`].Value' --output text)
            
            if [[ "$isCloudNativeBackup"  == "CNB-DAILY" ||  "$isCloudNativeBackup"  == "CNB-WEEKLY" || "$isCloudNativeBackup_Mor"  == "CNB-DAILY" ||  "$isCloudNativeBackup_Mor"  == "CNB-WEEKLY" ]]
            then
                echo -e "$(date "+%m%d%Y %T") : Disabling Backup"
                aws ec2 delete-tags --resources $instanceid --tags Key=CMP_BACKUP
                echo -e "$(date "+%m%d%Y %T") : Backups have been Disabled"

                echo -e "$(date "+%m%d%Y %T") : Deleting Backup"
                VAULT_NAME="Default"
                REGION=$(aws ec2 describe-availability-zones --output text --query 'AvailabilityZones[0].[RegionName]')
                ACCOUNT_NUMBER=$(aws sts get-caller-identity --output text --query 'Account')
                echo -e "$(date "+%m%d%Y %T") : Deleting Backup for Instance"
                
                for ARN in $(aws backup list-recovery-points-by-resource --resource-arn arn:aws:ec2:$REGION:$ACCOUNT_NUMBER:instance/$instanceid --query 'RecoveryPoints[].RecoveryPointArn' --output text); do
                    echo "Deleting Recovery Point ${ARN}"
                    aws backup delete-recovery-point --backup-vault-name "${VAULT_NAME}" --recovery-point-arn "${ARN}"
                done
                echo "Backups of AWS Instance have been Deleted"
            else
                echo -e "$(date "+%m%d%Y %T") : Its not AWS Machine with Cloud Native Backup Enabled"
            fi
    else
        echo -e "$(date "+%m%d%Y %T") : Its not AWS Machine with Cloud Native/CommVault Backup Enabled"
    fi   

else
    echo -e "$(date "+%m%d%Y %T") : Its not AWS/AZURE Machine with Cloud Native Backup/CommVault Enabled"
fi

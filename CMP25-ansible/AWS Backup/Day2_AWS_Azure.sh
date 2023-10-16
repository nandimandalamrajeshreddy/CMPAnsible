#!/bin/bash
isCloudNativeBackup_Day2="<%=customOptions.CMP_BACKUP_DAY2%>"
cloudtype=<%=zone.cloudTypeCode%>

if [ "$cloudtype" == "azure" ]
then
vm=<%=instance.name%>
username=<%=cypher.read('secret/spnusername')%>
password=<%=cypher.read('secret/spnpassword')%>
tenent=<%=cypher.read('secret/spntenent')%>
rcv=<%=cypher.read('secret/recovaryvault')%>
	az login --service-principal --username $username --password $password --tenant $tenent
	vmVal="/$vm/p"
	rg=$(az resource list | sed -n $vmVal | head -1 | grep -Po 'resourceGroups/\K.*(?=/providers)') 
    echo -e "$(date "+%m%d%Y %T") : Backup related activity for $vm Instance....."
	echo -e $isCloudNativeBackup_Day2
	if [ "$isCloudNativeBackup_Day2"  == "REDAILYBKP" ]
	then
		az backup protection resume --container-name $vm --policy-name DefaultPolicy --item-name $vm --resource-group $rg --vault-name $rcv --backup-management-type AzureIaasVM
		echo "DAILY Backup of AZURE Instance $vm has been resumed"

	elif [ "$isCloudNativeBackup_Day2"  == "REWEEKLYBKP" ]
	then
		az backup protection resume --container-name $vm --policy-name CNB-WEEKLY --item-name $vm --resource-group $rg --vault-name $rcv --backup-management-type AzureIaasVM
		echo "WEEKLY Backup of AZURE Instance $vm has been resumed"

	elif [ "$isCloudNativeBackup_Day2"  == "ENDAILYBKP" ]
	then
		az backup protection enable-for-vm --resource-group $rg --vault-name $rcv --vm $vm --policy-name DefaultPolicy
		echo "DAILY Backup of AZURE Instance $vm has been Enabled"

	elif [ "$isCloudNativeBackup_Day2"  == "ENWEEKLYBKP" ]
	then
		az backup protection enable-for-vm --resource-group $rg --vault-name $rcv --vm $vm --policy-name CNB-WEEKLY
		echo "WEEKLY Backup of AZURE Instance $vm has been Enabled"

	elif [ "$isCloudNativeBackup_Day2"  == "DISRETAINBKP" ]
	then
		az backup protection disable --resource-group $rg --vault-name $rcv --backup-management-type AzureIaasVM --container-name $vm --item-name $vm --delete-backup-data false --yes
		echo "Backup of AZURE Instance $vm has been Disabled and Backup is retained"

	elif [ "$isCloudNativeBackup_Day2"  == "DISDELBKP" ]
	then
		az backup protection disable --resource-group $rg --vault-name $rcv --backup-management-type AzureIaasVM --container-name $vm --item-name $vm --delete-backup-data true --yes
		echo "Backup of AZURE Instance $vm has been Disabled and Backup is Deleted"

	else
		echo -e "$(date "+%m%d%Y %T") : $vm is not enabled with Cloud Native Backup"
	fi
	az logout

elif [ "$cloudtype" == "amazon" ]
then
instanceName=<%=instance.name%>
instanceid=<%=server.externalId%>
    if [ "$isCloudNativeBackup_Day2"  == "REDAILYBKP" ]
    then
        echo -e "$(date "+%m%d%Y %T") : Resuming Daily Backup"
        aws ec2 create-tags --resources $instanceid --tags Key=CMP_BACKUP,Value=CNB-DAILY
        echo -e "$(date "+%m%d%Y %T") : Daily Backups have been Resumed"
    
    elif [ "$isCloudNativeBackup_Day2"  == "REWEEKLYBKP" ]
	then
        echo -e "$(date "+%m%d%Y %T") : Resuming Weekly Backup"
        aws ec2 create-tags --resources $instanceid --tags Key=CMP_BACKUP,Value=CNB-WEEKLY
        echo -e "$(date "+%m%d%Y %T") : Weekly Backups have been Resumed"
    
    elif [ "$isCloudNativeBackup_Day2"  == "ENDAILYBKP" ]
	then
        echo -e "$(date "+%m%d%Y %T") : Enabling Daily Backup"
        aws ec2 create-tags --resources $instanceid --tags Key=CMP_BACKUP,Value=CNB-DAILY
        echo -e "$(date "+%m%d%Y %T") : Daily Backups have been Enabled"
    
    elif [ "$isCloudNativeBackup_Day2"  == "ENWEEKLYBKP" ]
	then
        echo -e "$(date "+%m%d%Y %T") : Enabling Weekly Backup"
        aws ec2 create-tags --resources $instanceid --tags Key=CMP_BACKUP,Value=CNB-WEEKLY
        echo -e "$(date "+%m%d%Y %T") : Weekly Backups have been Enabled"
    
    elif [ "$isCloudNativeBackup_Day2"  == "DISRETAINBKP" ]
    then
        isCloudNativeBackup=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instanceid"  --query 'Tags[?Key==`CMP_BACKUP`].Value' --output text)
            if [[ "$isCloudNativeBackup"  == "CNB-DAILY" ||  "$isCloudNativeBackup"  == "CNB-WEEKLY" ]]
            then
                echo -e "$(date "+%m%d%Y %T") : Disabling Backup"
                aws ec2 delete-tags --resources $instanceid --tags Key=CMP_BACKUP
                echo -e "$(date "+%m%d%Y %T") : Backups have been Disabled"
            else
                echo -e "$(date "+%m%d%Y %T") : Its not AWS Machine with Cloud Native Backup Enabled"
            fi

    elif [ "$isCloudNativeBackup_Day2"  == "DISDELBKP" ]
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
        echo -e "$(date "+%m%d%Y %T") : Its not AWS Machine with Cloud Native Backup Enabled"
    fi   


else
    echo -e "$(date "+%m%d%Y %T") : Its not AWS/AZURE Machine with Cloud Native Backup Enabled"
fi

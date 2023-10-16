#!/bin/bash
cloudtype=<%=zone.cloudTypeCode%>
instanceName=<%=instance.name%>
instanceid=<%=server.externalId%>
isCloudNativeBackup="<%=customOptions.CMP_BACKUP%>"

if [ "$cloudtype" == "amazon" ] && [[ "$isCloudNativeBackup"  == "CNB-DAILY" ||  "$isCloudNativeBackup"  == "CNB-WEEKLY" ]]
then
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
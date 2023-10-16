#!/bin/bash
cloudtype=<%=zone.cloudTypeCode%>
instanceName=<%=instance.name%>
instanceid=<%=server.externalId%>
#isCloudNativeBackup="<%=customOptions.CMP_BACKUP%>"
if [ "$cloudtype" == "amazon" ]
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

else
    echo -e "$(date "+%m%d%Y %T") : Its not AWS Instance"
fi
#!/bin/bash
cloudtype=<%=zone.cloudTypeCode%>
instanceName=<%=instance.name%>
instanceid=<%=server.externalId%>
isCloudNativeBackup="<%=customOptions.CMP_BACKUP%>"
if [ "$cloudtype" == "amazon" ]
then
    echo -e "$(date "+%m%d%Y %T") : Enabling Weekly Backup"
    aws ec2 create-tags --resources $instanceid --tags Key=CMP_BACKUP,Value=CNB-WEEKLY
    echo -e "$(date "+%m%d%Y %T") : Weekly Backups have been Enabled"

else
    echo -e "$(date "+%m%d%Y %T") : Its not AWS Machine with Cloud Native Backup Enabled"
fi
#!/bin/bash
cloudtype=<%=zone.cloudTypeCode%>
instanceName=<%=instance.name%>
isCloudNativeMonitoring="<%=customOptions.CMP_MONITOR%>"
if [ "$cloudtype" == "amazon" ] && [ "$isCloudNativeMonitoring"  == "MonitorLinux" ]
then
echo -e "$(date "+%m%d%Y %T") : Disabling Alarms"
aws cloudwatch delete-alarms --alarm-names $instanceName-CPU-Utilization-Alarm $instanceName-StatusCheckFailed-Alarm $instanceName-Memory-Utilization-Alarm $instanceName-Disk-Utilization-Alarm
echo -e "$(date "+%m%d%Y %T") : Alarms have been Disabled"
else
echo -e "$(date "+%m%d%Y %T") : Its not AWS Machine with Cloud Native Monitoring Enabled"
fi
$isCloudNativeMonitoring="<%=customOptions.CMP_MONITOR%>"
$cloudtype="<%=zone.cloudTypeCode%>"
$instanceName="<%=instance.name%>"
if ($cloudType -eq "amazon" -and $isCloudNativeMonitoring -eq "MonitorWindows")
{
Write-Output "Disabling the Alarms"
& "C:\Program Files\Amazon\AWSCLI\bin\aws.exe" cloudwatch delete-alarms --alarm-names $instanceName-CPU-Utilization-Alarm $instanceName-StatusCheckFailed-Alarm $instanceName-Memory-Utilization-Alarm $instanceName-Disk-Utilization-Alarm

Write-Output "Alarms have been Disabled"
}
else 
{
	Write-Output "Its Not a AWS Windows Instance with Cloud Monitoring Enabled"
}
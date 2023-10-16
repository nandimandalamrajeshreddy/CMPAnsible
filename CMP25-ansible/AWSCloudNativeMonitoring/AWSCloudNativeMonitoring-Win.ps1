$isCloudNativeMonitoring="<%=customOptions.CMP_MONITOR%>"
$cloudtype="<%=zone.cloudTypeCode%>"
$instanceName="<%=instance.name%>"
Write-Output "$cloudtype, $isCloudNativeMonitoring, $instanceName"


if ($cloudType -eq "amazon" -and $isCloudNativeMonitoring -eq "MonitorWindows")
{
    $REGION=(Invoke-RestMethod "http://169.254.169.254/latest/dynamic/instance-identity/document").region
    Invoke-WebRequest -Uri https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/AmazonCloudWatchAgent.zip -OutFile $env:TEMP\AmazonCloudWatchAgent.zip

    Expand-Archive -Path "$env:TEMP\AmazonCloudWatchAgent.zip" -DestinationPath "$env:TEMP\AmazonCloudWatchAgent"

    Set-Location -Path "$env:TEMP\AmazonCloudWatchAgent"
    .\install.ps1

    Set-Location -Path 'C:\Program Files\Amazon\AmazonCloudWatchAgent'

    .\amazon-cloudwatch-agent-ctl.ps1 -m ec2 -a status
    Write-Output "Started Cloudwatch Agent Service"
    .\amazon-cloudwatch-agent-ctl.ps1 -m ec2 -a start 
    .\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m ec2 -c ssm:AmazonCloudWatch-windows -s

    Write-Output "Installing AWSCLI"
    $dlurl = "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi"
    $installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
    Invoke-WebRequest $dlurl -OutFile $installerPath
    Start-Process -FilePath msiexec -Args "/i $installerPath /passive" -Verb RunAs -Wait
    Remove-Item $installerPath
    
    Write-Output "Creating Alarms for CloudNative Monitoring Metrics"
    $AMI_ID=Get-EC2InstanceMetadata -Category AmiId
    $EC2_INSTANCE_ID=Get-EC2InstanceMetadata -Category InstanceId
    $InstanceType=Get-EC2InstanceMetadata -Category InstanceType
    $ACCOUNT_NUMBER=& "C:\Program Files\Amazon\AWSCLI\bin\aws.exe" sts get-caller-identity --output text --query 'Account'
    Write-Output "The Instance ID, InstanceType, AMI-ID and Account Number are are $EC2_INSTANCE_ID, $InstanceType, $AMI_ID, $ACCOUNT_NUMBER"
    

    & "C:\Program Files\Amazon\AWSCLI\bin\aws.exe" configure set region $REGION

    Write-Output "Creating Cloudwatch Alarm for CPU Utilization"
    & "C:\Program Files\Amazon\AWSCLI\bin\aws.exe" cloudwatch put-metric-alarm --alarm-name $instanceName-CPU-Utilization-Alarm --alarm-description "Alarm when CPU exceeds 90 percent" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=$EC2_INSTANCE_ID" --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION':'$ACCOUNT_NUMBER':'Default_CloudWatch_Alarms_Topic --unit Percent

    Write-Output "Creating Cloudwatch Alarm for StatusCheckFailed"
    & "C:\Program Files\Amazon\AWSCLI\bin\aws.exe" cloudwatch put-metric-alarm --alarm-name $instanceName-StatusCheckFailed-Alarm --alarm-description "Alarm when Status Check Fails" --metric-name StatusCheckFailed --namespace AWS/EC2 --statistic Average --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold  --dimensions "Name=InstanceId,Value=$EC2_INSTANCE_ID" --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION':'$ACCOUNT_NUMBER':'Default_CloudWatch_Alarms_Topic

    Write-Output "Creating Cloudwatch Alarm for Memory Utilization"
    & "C:\Program Files\Amazon\AWSCLI\bin\aws.exe" cloudwatch  put-metric-alarm --alarm-name $instanceName-Memory-Utilization-Alarm --alarm-description "Alarm when Memort exceeds 90 percent" --metric-name "Memory % Committed Bytes In Use" --namespace CWAgent --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanThreshold  --dimensions Name=InstanceId,Value=$EC2_INSTANCE_ID Name=InstanceType,Value=$InstanceType Name=ImageId,Value=$AMI_ID Name=objectname,Value=Memory --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION':'$ACCOUNT_NUMBER':'Default_CloudWatch_Alarms_Topic

    Write-Output "Creating Cloudwatch Alarm for Disk Utilization"
    & "C:\Program Files\Amazon\AWSCLI\bin\aws.exe" cloudwatch  put-metric-alarm --alarm-name $instanceName-Disk-Utilization-Alarm --alarm-description "Alarm when Disk Free Space is less than 10 percent" --metric-name "LogicalDisk % Free Space" --namespace CWAgent --statistic Average --period 300 --threshold 10 --comparison-operator LessThanThreshold  --dimensions Name=InstanceId,Value=$EC2_INSTANCE_ID Name=instance,Value=C: Name=InstanceType,Value=$InstanceType Name=ImageId,Value=$AMI_ID Name=objectname,Value=LogicalDisk --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION':'$ACCOUNT_NUMBER':'Default_CloudWatch_Alarms_Topic
}
else 
{
	Write-Output "Its Not a AWS Windows Instance with Cloud Monitoring Enabled"
}
#!/bin/bash
source /etc/os-release
isCloudNativeMonitoring="<%=customOptions.CMP_MONITOR%>"
cloudtype=<%=zone.cloudTypeCode%>
instanceName=<%=instance.name%>
Filesystem_value=$(df -h / | tail -1 | awk '{print $1}')
RHEL_VERSION_ID=$(echo $VERSION_ID | cut -b 1)
echo -e "$(date "+%m%d%Y %T") : The Task Execution Initiated"
echo -e "$(date "+%m%d%Y %T") : Operating System is $ID"
echo -e "$(date "+%m%d%Y %T") : The Instance Name is $instanceName"


if [ "$ID"  == "ubuntu" ] && [ "$cloudtype" == "amazon" ] && [ "$isCloudNativeMonitoring"  == "MonitorLinux" ]
then
REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`
EC2_INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
echo -e "$(date "+%m%d%Y %T") : Region and Instance ID are $REGION and $EC2_INSTANCE_ID"
echo -e "$(date "+%m%d%Y %T") : Installing AWSCLI, and Unzip Package"
cd ~ && pwd
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
aws --version

echo -e "$(date "+%m%d%Y %T") : Monitoring Memory and Disk metrics"
sudo apt-get update -y
sudo apt-get install libwww-perl libdatetime-perl -y
cd ~ && pwd

curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip -O
unzip CloudWatchMonitoringScripts-1.2.2.zip && rm -rf CloudWatchMonitoringScripts-1.2.2.zip && cd aws-scripts-mon
./mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/

echo -e "$(date "+%m%d%Y %T") : Creating CronJob to Push the Metrics in every 1 Min"
crontab -l | { cat; echo "*/5 * * * * ~/aws-scripts-mon/mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/ --from-cron"; } | crontab -

ACCOUNT_NUMBER=$(aws sts get-caller-identity --output text --query 'Account')

echo -e "$(date "+%m%d%Y %T") : Creating Cloudwatch Alarm for CPU Utilization"
aws cloudwatch put-metric-alarm --alarm-name $instanceName-CPU-Utilization-Alarm --alarm-description "Alarm when CPU exceeds 90 percent" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=$EC2_INSTANCE_ID" --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION:$ACCOUNT_NUMBER:Default_CloudWatch_Alarms_Topic --unit Percent

echo -e "$(date "+%m%d%Y %T") : Creating Cloudwatch Alarm for StatusCheckFailed"
aws cloudwatch put-metric-alarm --alarm-name $instanceName-StatusCheckFailed-Alarm --alarm-description "Alarm when Status Check Fails" --metric-name StatusCheckFailed --namespace AWS/EC2 --statistic Average --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold  --dimensions "Name=InstanceId,Value=$EC2_INSTANCE_ID" --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION:$ACCOUNT_NUMBER:Default_CloudWatch_Alarms_Topic

echo -e "$(date "+%m%d%Y %T") : Creating Cloudwatch Alarm for Memory Utilization"
aws cloudwatch put-metric-alarm --alarm-name $instanceName-Memory-Utilization-Alarm --alarm-description "Alarm when Memory exceeds 90 percent" --metric-name MemoryUtilization --namespace System/Linux --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=$EC2_INSTANCE_ID" --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION:$ACCOUNT_NUMBER:Default_CloudWatch_Alarms_Topic --unit Percent

echo -e "$(date "+%m%d%Y %T") : Creating Cloudwatch Alarm for Disk Utilization"
aws cloudwatch put-metric-alarm --alarm-name $instanceName-Disk-Utilization-Alarm --alarm-description "Alarm when Disk exceeds 90 percent" --metric-name DiskSpaceUtilization --namespace System/Linux --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanThreshold  --dimensions Name=InstanceId,Value=$EC2_INSTANCE_ID Name=Filesystem,Value=${Filesystem_value} Name=MountPath,Value=/ --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION:$ACCOUNT_NUMBER:Default_CloudWatch_Alarms_Topic --unit Percent


elif [ "$ID"  == "rhel" ] && [ "$RHEL_VERSION_ID" == "7" ] && [ "$cloudtype" == "amazon" ] && [ "$isCloudNativeMonitoring"  == "MonitorLinux" ]
then
REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`
EC2_INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
echo -e "$(date "+%m%d%Y %T") : Region and Instance ID are $REGION and $EC2_INSTANCE_ID"
echo -e "$(date "+%m%d%Y %T") : Installing AWSCLI, and Unzip Package "
cd ~ && pwd
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo yum install unzip -y
unzip awscliv2.zip
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
aws --version
aws configure set region $REGION

echo -e "$(date "+%m%d%Y %T") : Monitoring Memory and Disk metrics"
sudo yum install perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA --enablerepo="rhel-7-server-rhui-optional-rpms" -y 

cd ~ && pwd
curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip -O
unzip CloudWatchMonitoringScripts-1.2.2.zip && rm -rf CloudWatchMonitoringScripts-1.2.2.zip && cd aws-scripts-mon
./mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/

echo -e "$(date "+%m%d%Y %T") : Creating CronJob to Push the Metrics in every 1 Min"
crontab -l | { cat; echo "*/5 * * * * ~/aws-scripts-mon/mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/ --from-cron"; } | crontab -

ACCOUNT_NUMBER=$(aws sts get-caller-identity --output text --query 'Account')

echo -e "$(date "+%m%d%Y %T") : Creating Cloudwatch Alarm for CPU Utilization"
aws cloudwatch put-metric-alarm --alarm-name $instanceName-CPU-Utilization-Alarm --alarm-description "Alarm when CPU exceeds 90 percent" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=$EC2_INSTANCE_ID" --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION:$ACCOUNT_NUMBER:Default_CloudWatch_Alarms_Topic --unit Percent

echo -e "$(date "+%m%d%Y %T") : Creating Cloudwatch Alarm for StatusCheckFailed"
aws cloudwatch put-metric-alarm --alarm-name $instanceName-StatusCheckFailed-Alarm --alarm-description "Alarm when Status Check Fails" --metric-name StatusCheckFailed --namespace AWS/EC2 --statistic Average --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold  --dimensions "Name=InstanceId,Value=$EC2_INSTANCE_ID" --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION:$ACCOUNT_NUMBER:Default_CloudWatch_Alarms_Topic

echo -e "$(date "+%m%d%Y %T") : Creating Cloudwatch Alarm for Memory Utilization"
aws cloudwatch put-metric-alarm --alarm-name $instanceName-Memory-Utilization-Alarm --alarm-description "Alarm when Memory exceeds 90 percent" --metric-name MemoryUtilization --namespace System/Linux --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=$EC2_INSTANCE_ID" --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION:$ACCOUNT_NUMBER:Default_CloudWatch_Alarms_Topic --unit Percent

echo -e "$(date "+%m%d%Y %T") : Creating Cloudwatch Alarm for Disk Utilization"
aws cloudwatch put-metric-alarm --alarm-name $instanceName-Disk-Utilization-Alarm --alarm-description "Alarm when Disk exceeds 90 percent" --metric-name DiskSpaceUtilization --namespace System/Linux --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanThreshold  --dimensions Name=InstanceId,Value=$EC2_INSTANCE_ID Name=Filesystem,Value=${Filesystem_value} Name=MountPath,Value=/ --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION:$ACCOUNT_NUMBER:Default_CloudWatch_Alarms_Topic --unit Percent




elif [ "$ID"  == "centos" ] && [ "$VERSION_ID" == "7" ] && [ "$cloudtype" == "amazon" ] && [ "$isCloudNativeMonitoring"  == "MonitorLinux" ]
then
REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`
EC2_INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
echo -e "$(date "+%m%d%Y %T") : Region and Instance ID are $REGION and $EC2_INSTANCE_ID"
echo -e "$(date "+%m%d%Y %T") : Installing AWSCLI, and Unzip Package "
cd ~ && pwd
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo yum install unzip -y
unzip awscliv2.zip
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
aws --version
aws configure set region $REGION

echo -e "$(date "+%m%d%Y %T") : Monitoring Memory and Disk metrics"
yum install epel-release -y
sudo yum install perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA -y

cd ~ && pwd
curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip -O
unzip CloudWatchMonitoringScripts-1.2.2.zip && rm -rf CloudWatchMonitoringScripts-1.2.2.zip && cd aws-scripts-mon
./mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/

echo -e "$(date "+%m%d%Y %T") : Creating CronJob to Push the Metrics in every 1 Min"
crontab -l | { cat; echo "*/5 * * * * ~/aws-scripts-mon/mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --mem-used --mem-avail --disk-space-util --disk-path=/ --from-cron"; } | crontab -

ACCOUNT_NUMBER=$(aws sts get-caller-identity --output text --query 'Account')

echo -e "$(date "+%m%d%Y %T") : Creating Cloudwatch Alarm for CPU Utilization"
aws cloudwatch put-metric-alarm --alarm-name $instanceName-CPU-Utilization-Alarm --alarm-description "Alarm when CPU exceeds 90 percent" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=$EC2_INSTANCE_ID" --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION:$ACCOUNT_NUMBER:Default_CloudWatch_Alarms_Topic --unit Percent

echo -e "$(date "+%m%d%Y %T") : Creating Cloudwatch Alarm for StatusCheckFailed"
aws cloudwatch put-metric-alarm --alarm-name $instanceName-StatusCheckFailed-Alarm --alarm-description "Alarm when Status Check Fails" --metric-name StatusCheckFailed --namespace AWS/EC2 --statistic Average --period 300 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold  --dimensions "Name=InstanceId,Value=$EC2_INSTANCE_ID" --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION:$ACCOUNT_NUMBER:Default_CloudWatch_Alarms_Topic

echo -e "$(date "+%m%d%Y %T") : Creating Cloudwatch Alarm for Memory Utilization"
aws cloudwatch put-metric-alarm --alarm-name $instanceName-Memory-Utilization-Alarm --alarm-description "Alarm when Memory exceeds 90 percent" --metric-name MemoryUtilization --namespace System/Linux --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanThreshold  --dimensions "Name=InstanceId,Value=$EC2_INSTANCE_ID" --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION:$ACCOUNT_NUMBER:Default_CloudWatch_Alarms_Topic --unit Percent

echo -e "$(date "+%m%d%Y %T") : Creating Cloudwatch Alarm for Disk Utilization"
aws cloudwatch put-metric-alarm --alarm-name $instanceName-Disk-Utilization-Alarm --alarm-description "Alarm when Disk exceeds 90 percent" --metric-name DiskSpaceUtilization --namespace System/Linux --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanThreshold  --dimensions Name=InstanceId,Value=$EC2_INSTANCE_ID Name=Filesystem,Value=${Filesystem_value} Name=MountPath,Value=/ --evaluation-periods 1 --alarm-actions arn:aws:sns:$REGION:$ACCOUNT_NUMBER:Default_CloudWatch_Alarms_Topic --unit Percent


else
echo -e "$(date "+%m%d%Y %T") : Its Not a Amazon Centos 7 / RHEL 7 / Ubuntu 18.04 Machine with AWS Cloud Native Monitoring Enabled"
fi

echo -e "$(date "+%m%d%Y %T") : The Task Execution Completed"

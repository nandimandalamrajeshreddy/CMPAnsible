#!/bin/bash
source /etc/os-release
cloudtype=<%=zone.cloudTypeCode%>
isCloudNative="<%=customOptions.CMP_PATCH%>"
if [ "$ID"  == "centos" -a "$VERSION_ID" == "7" ] && [ "$cloudtype" == "amazon" ]
then
	echo -e "$(date "+%m%d%Y %T") : Operating System is $ID-$VERSION_ID"

	echo -e "$(date "+%m%d%Y %T") : Download and run the SSM Agent installer"
    sudo yum install -y https://s3.us-east-2.amazonaws.com/amazon-ssm-us-east-2/latest/linux_amd64/amazon-ssm-agent.rpm

    echo -e "$(date "+%m%d%Y %T") : Determine if SSM Agent is running"
    sudo systemctl status amazon-ssm-agent

    echo -e "$(date "+%m%d%Y %T") : Start the service"
    sudo systemctl enable amazon-ssm-agent 
    sudo systemctl start amazon-ssm-agent

    echo -e "$(date "+%m%d%Y %T") : Check the status of the agent"
    sudo systemctl status amazon-ssm-agent

elif [ "$ID"  == "rhel" ] && [ "$cloudtype" == "amazon" ] && [ "$isCloudNative" == "ProductionLinux" ] 
then
	echo -e "$(date "+%m%d%Y %T") : Operating System is $ID-$VERSION_ID"
    
	echo -e "$(date "+%m%d%Y %T") : Install Python for SSM Agent"
    sudo yum install python2 -y
    sudo yum install python3 -y
    

	echo -e "$(date "+%m%d%Y %T") : Download and run the SSM Agent installer"
	sudo yum install -y https://s3.us-east-2.amazonaws.com/amazon-ssm-us-east-2/latest/linux_amd64/amazon-ssm-agent.rpm
    
    echo -e "$(date "+%m%d%Y %T") : Determine if SSM Agent is running"
    sudo systemctl status amazon-ssm-agent

    echo -e "$(date "+%m%d%Y %T") : Start the service"
    sudo systemctl enable amazon-ssm-agent 
    sudo systemctl start amazon-ssm-agent

    echo -e "$(date "+%m%d%Y %T") : Check the status of the agent"
    sudo systemctl status amazon-ssm-agent

else
echo -e "$(date "+%m%d%Y %T") : Its Not a AWS Centos 7 or RHEL 8 Machine with CloudNative Patching Enabled"
fi
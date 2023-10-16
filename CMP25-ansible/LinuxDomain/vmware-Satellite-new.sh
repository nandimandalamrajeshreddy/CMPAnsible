#!/bin/bash

echo -e "$(date "+%m%d%Y %T") : export GPG_TTY=$(tty)" >> ~/.profile
echo -e "$(date "+%m%d%Y %T") : Register this VM to Satellite"


source /etc/os-release
isSatellite="<%=customOptions.CMP_PATCH%>"
if [ "$isSatellite" == "SatellitePatch" ] 
then
echo -e "$(date "+%m%d%Y %T") : Operating System is $ID and Satellite Patching Status is $isSatellite"
#echo -e "13.68.246.57 cmp.satellite.server.east" >> /etc/hosts

echo -e "$(date "+%m%d%Y %T") : Downloading the rpm packages from satellite server"

curl --insecure --output katello-ca-consumer-latest.noarch.rpm https://satellite.dev.cmp.unisys-waf.com/pub/katello-ca-consumer-latest.noarch.rpm

echo -e "$(date "+%m%d%Y %T") : Installing the package from satellite server"

yum localinstall katello-ca-consumer-latest.noarch.rpm -y

subscription-manager register --org="unisys" --activationkey="unisys-dev" --force

echo -e "$(date "+%m%d%Y %T") : Obtain subscription Pool ID"
subscription-manager list --available > pool-id.txt
poolid=$(awk '/Pool ID/{print $NF}' pool-id.txt > pool-id1.txt && sed '2q;d' pool-id1.txt)

echo -e "$(date "+%m%d%Y %T") : Pool ID is $poolid"

echo -e "$(date "+%m%d%Y %T") : Attach subscription with the the Pool ID Retrieved"
subscription-manager attach --pool=$poolid

echo -e "$(date "+%m%d%Y %T") : List enabled repositories by using the dnf command"
dnf repolist

echo -e "$(date "+%m%d%Y %T") : Use the subscription-manager command to first list all available repositories"
subscription-manager repos --list 

echo -e "$(date "+%m%d%Y %T") : To enable all repositories execute"
subscription-manager repos  --enable="*"

yum -y install katello-host-tools

yum -y install katello-host-tools-tracer

yum -y install katello-agent

dnf uploadprofile --force-upload

else
echo -e "$(date "+%m%d%Y %T") : Its not a Centos VM or RHEL vm with Satellite Enabled"
fi
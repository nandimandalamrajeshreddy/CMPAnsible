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

subscription-manager repos  --enable="*"

yum -y install katello-host-tools

yum -y install katello-host-tools-tracer

yum -y install katello-agent

dnf uploadprofile --force-upload

else
echo -e "$(date "+%m%d%Y %T") : Its not a Centos VM or RHEL vm with Satellite Enabled"
fi
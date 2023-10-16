#!/bin/bash
source /etc/os-release
cloudtype=<%=zone.cloudTypeCode%>
instanceName=<%=instance.name%>
RHEL_VERSION_ID=$(echo $VERSION_ID | cut -b 1)
echo -e "$(date "+%m%d%Y %T") : Operating System is $ID"
echo -e "$(date "+%m%d%Y %T") : The Instance Name is $instanceName"

if [ "$ID"  == "ubuntu" ] 
then
echo 10.1.0.4 CMPDEVAD1.cloudforte.com CMPDEVAD1 >> /etc/hosts
echo 127.0.0.1 $instanceName $instanceName.cloudforte.com >> /etc/hosts

echo nameserver 10.1.0.4 > /etc/resolv.conf
export DEBIAN_FRONTEND=noninteractive
echo -e "$(date "+%m%d%Y %T") : Install All Necessary Packages"
sudo apt-get install realmd sssd sssd-tools samba-common packagekit samba-common-bin samba-libs adcli ntp -y 
apt-get install krb5-user -y

wget https://s3-cmp-commvault-bucket.s3.amazonaws.com/ubuntu-krb5.conf
sudo mv ubuntu-krb5.conf /etc/krb5.conf
echo -e "$(date "+%m%d%Y %T") : Setup NTP Service to point to Domain Timeserver"
sudo echo server cmpdevad1.CLOUDFORTE.COM >> /etc/ntp.conf
sudo service ntp restart

echo -e "$(date "+%m%d%Y %T") : Setting up realmd"
wget https://s3-cmp-commvault-bucket.s3.amazonaws.com/ubuntu-realmd.conf
sudo mv ubuntu-realmd.conf /etc/realmd.conf

echo -e "$(date "+%m%d%Y %T") : Join the Ubuntu Machime on the AD domain"
echo 'Unisys*123' | sudo kinit cmpadmin@CLOUDFORTE.COM
echo 'Unisys*123' | sudo realm join CMPDEVAD1.CLOUDFORTE.COM -U 'cmpadmin@CLOUDFORTE.COM' -v

echo -e "$(date "+%m%d%Y %T") : Setting up sssd"
wget https://s3-cmp-commvault-bucket.s3.amazonaws.com/ubuntu-sssd.conf
sudo mv ubuntu-sssd.conf /etc/sssd/sssd.conf
sudo chown root:root /etc/sssd/sssd.conf
sudo chmod 600 /etc/sssd/sssd.conf
sudo service sssd restart

echo -e "$(date "+%m%d%Y %T") : Setup homedir auto-creation for new users"
echo session required pam_mkhomedir.so skel=/etc/skel/ umask=0077 >> /etc/pam.d/common-session

echo -e "$(date "+%m%d%Y %T") : Added Sudo Privileges"
sudo echo "%MorpheusAdmins  ALL=(ALL)   ALL" >> /etc/sudoers.d/sudoers
sudo echo "%MorpheusUsers   ALL=(ALL)   ALL" >> /etc/sudoers.d/sudoers



elif [ "$ID"  == "rhel" ] && [ "$RHEL_VERSION_ID" == "7" ]
then
echo 10.1.0.4 CMPDEVAD1.cloudforte.com CMPDEVAD1 >> /etc/hosts
echo 127.0.0.1 $instanceName $instanceName.cloudforte.com >> /etc/hosts
echo nameserver 10.1.0.4 > /etc/resolv.conf

echo -e "$(date "+%m%d%Y %T") : Install All Necessary Packages"
sudo yum install sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation openldap-clients -y

echo -e "$(date "+%m%d%Y %T") : Join the RHEL Machime on the AD domain"
sudo realm discover CLOUDFORTE.COM
echo 'Unisys*123' | sudo kinit cmpadmin@CLOUDFORTE.COM
echo 'Unisys*123' | sudo realm join CMPDEVAD1.CLOUDFORTE.COM -U 'cmpadmin@CLOUDFORTE.COM' -v

echo -e "$(date "+%m%d%Y %T") : Setting up sssd"
wget https://s3-cmp-commvault-bucket.s3.amazonaws.com/rhel-sssd.conf
sudo mv rhel-sssd.conf /etc/sssd/sssd.conf
sudo chown root:root /etc/sssd/sssd.conf
sudo chmod 600 /etc/sssd/sssd.conf
sudo systemctl restart sssd
sudo systemctl daemon-reload

echo -e "$(date "+%m%d%Y %T") : Added Sudo Privileges"
sudo echo "%MorpheusAdmins  ALL=(ALL)   ALL" >> /etc/sudoers.d/sudoers
sudo echo "%MorpheusUsers   ALL=(ALL)   ALL" >> /etc/sudoers.d/sudoers

elif [ "$ID"  == "centos" ] && [ "$VERSION_ID" == "7" ]
then
echo 10.1.0.4 CMPDEVAD1.cloudforte.com CMPDEVAD1 >> /etc/hosts
echo 127.0.0.1 $instanceName $instanceName.cloudforte.com >> /etc/hosts
echo nameserver 10.1.0.4 > /etc/resolv.conf

echo -e "$(date "+%m%d%Y %T") : Install All Necessary Packages"
sudo yum install sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation openldap-clients -y

echo -e "$(date "+%m%d%Y %T") : Join the RHEL Machime on the AD domain"
sudo realm discover CLOUDFORTE.COM
echo 'Unisys*123' | sudo kinit cmpadmin@CLOUDFORTE.COM
echo 'Unisys*123' | sudo realm join CMPDEVAD1.CLOUDFORTE.COM -U 'cmpadmin@CLOUDFORTE.COM' -v

echo -e "$(date "+%m%d%Y %T") : Setting up sssd"
wget https://s3-cmp-commvault-bucket.s3.amazonaws.com/rhel-sssd.conf
sudo mv rhel-sssd.conf /etc/sssd/sssd.conf
sudo chown root:root /etc/sssd/sssd.conf
sudo chmod 600 /etc/sssd/sssd.conf
sudo systemctl restart sssd
sudo systemctl daemon-reload

echo -e "$(date "+%m%d%Y %T") : Added Sudo Privileges"
sudo echo "%MorpheusAdmins  ALL=(ALL)   ALL" >> /etc/sudoers.d/sudoers
sudo echo "%MorpheusUsers   ALL=(ALL)   ALL" >> /etc/sudoers.d/sudoers

elif [ "$ID"  == "rhel" ] && [ "$RHEL_VERSION_ID" == "8" ]
then
echo -e "$(date "+%m%d%Y %T") : Operating System is $ID-$RHEL_VERSION_ID"
echo 10.1.0.4 CMPDEVAD1.cloudforte.com CMPDEVAD1 >> /etc/hosts
echo 127.0.0.1 $instanceName $instanceName.cloudforte.com >> /etc/hosts
echo nameserver 10.1.0.4 > /etc/resolv.conf

echo -e "$(date "+%m%d%Y %T") : Install All Necessary Packages"
sudo dnf install sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation authselect-compat -y

echo -e "$(date "+%m%d%Y %T") : Join the RHEL Machime on the AD domain"
sudo realm discover CLOUDFORTE.COM
echo 'Unisys*123' | sudo kinit cmpadmin@CLOUDFORTE.COM
echo 'Unisys*123' | sudo realm join CMPDEVAD1.CLOUDFORTE.COM -U 'cmpadmin@CLOUDFORTE.COM' -v

echo -e "$(date "+%m%d%Y %T") : Setting up sssd"
setenforce 0
sudo authselect select sssd
sudo authselect select sssd with-mkhomedir
wget https://s3-cmp-commvault-bucket.s3.amazonaws.com/rhel-sssd.conf
sudo mv rhel-sssd.conf /etc/sssd/sssd.conf
sudo chown root:root /etc/sssd/sssd.conf
sudo chmod 600 /etc/sssd/sssd.conf
sudo systemctl restart sssd
sudo systemctl daemon-reload
setenforce 1

echo -e "$(date "+%m%d%Y %T") : Added Sudo Privileges"
sudo echo "%MorpheusAdmins  ALL=(ALL)   ALL" >> /etc/sudoers.d/sudoers
sudo echo "%MorpheusUsers   ALL=(ALL)   ALL" >> /etc/sudoers.d/sudoers

elif [ "$ID"  == "centos" ] && [ "$VERSION_ID" == "8" ]
then
echo 10.1.0.4 CMPDEVAD1.cloudforte.com CMPDEVAD1 >> /etc/hosts
echo 127.0.0.1 $instanceName $instanceName.cloudforte.com >> /etc/hosts
echo nameserver 10.1.0.4 > /etc/resolv.conf

echo -e "$(date "+%m%d%Y %T") : Install All Necessary Packages"
sudo dnf install sssd realmd oddjob oddjob-mkhomedir adcli samba-common samba-common-tools krb5-workstation authselect-compat -y

echo -e "$(date "+%m%d%Y %T") : Join the RHEL Machime on the AD domain"
sudo realm discover CLOUDFORTE.COM
echo 'Unisys*123' | sudo kinit cmpadmin@CLOUDFORTE.COM
echo 'Unisys*123' | sudo realm join CMPDEVAD1.CLOUDFORTE.COM -U 'cmpadmin@CLOUDFORTE.COM' -v

echo -e "$(date "+%m%d%Y %T") : Setting up sssd"
setenforce 0
sudo authselect select sssd
sudo authselect select sssd with-mkhomedir
wget https://s3-cmp-commvault-bucket.s3.amazonaws.com/rhel-sssd.conf
sudo mv rhel-sssd.conf /etc/sssd/sssd.conf
sudo chown root:root /etc/sssd/sssd.conf
sudo chmod 600 /etc/sssd/sssd.conf
sudo systemctl restart sssd
sudo systemctl daemon-reload
setenforce 1

echo -e "$(date "+%m%d%Y %T") : Added Sudo Privileges"
sudo echo "%MorpheusAdmins  ALL=(ALL)   ALL" >> /etc/sudoers.d/sudoers
sudo echo "%MorpheusUsers   ALL=(ALL)   ALL" >> /etc/sudoers.d/sudoers


else
echo -e "$(date "+%m%d%Y %T") : Its Not a Amazon Centos / RHEL / Ubuntu Machine"
fi
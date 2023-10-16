$instanceName="<%=instance.name%>"
$PrivateIp="<%=server.internalIp%>"
Write-Output "Adding the Machine to the Windows Domain Name Server"
Add-DnsServerResourceRecordA -Name "$instanceName" -ZoneName "cloudforte.com" -AllowUpdateAny -IPv4Address "$PrivateIp" -TimeToLive 01:00:00

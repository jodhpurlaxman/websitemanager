#!/bin/bash

echo "Enter the Static IP : "  
read IP
/sbin/ip -4 -o a | cut -d ' ' -f 2,7 | cut -d '/' -f 1 | grep enp2s0
if [ $? == 0 ]; then
  ETH0=enp2s0
  else
  echo "Enter the main ethernet adaptor name : "  
read ETH0
fi

#add static IP based upon netplan or networkd
if [ $OS == '"Ubuntu"' && ! -f /etc/netplan/01-netcfg.yaml  ];
then 
cat << EOT >  /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    $ETH0:
      addresses:
        - $IP/24
      routes:
        - to: default
          via: 192.168.0.1
      nameservers:
          addresses: [1.1.1.1, 8.8.8.8, 4.4.4.4]
EOT
else
cat << EOT > > /etc/netplan/01-netcfg.yaml
source /etc/network/interfaces.d/*
# The loopback network interface
auto lo
iface lo inet loopback
# The eth0 network interface
auto $ETH0
iface $ETH0 inet static 
  address $IP
  netmask 255.255.255.0
  gateway 192.168.0.1
  dns-nameservers 1.1.1.1
  dns-nameservers 8.8.8.8
  dns-nameservers 8.8.4.4
EOT
fi

if ! grep -Fxq "/opt/websitemanager/network/internetsw.sh" /var/spool/cron/crontabs/root
then
    chmod -x /opt/websitemanager/network/internetsw.sh
    (crontab -l 2>/dev/null; echo "* * * * * /opt/websitemanager/network/internetsw.sh") | crontab -
fi

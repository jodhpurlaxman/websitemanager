#!/bin/bash
OS=$(cat /etc/os-release | sed -n '1p' | awk -F "=" '{print $2}')
echo "Enter the Static IP like 192.168.0.200(not_same): "  
read IP
echo "#Below are the name of your sys networkcards :"  
/sbin/ip -4 -o a | cut -d ' ' -f 2,7 | cut -d '/' -f 1
echo "#End of networkcards list"  

echo "Enter the main ethernet adaptor name : "  
read ETH0
rm -f /etc/netplan/01-netcfg.yaml
#add static IP based upon netplan or networkd
if [[ $OS == '"Ubuntu"' ]] && [[ ! -f '/etc/netplan/01-netcfg.yaml' ]]; then
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
cat << EOT >  /etc/network/interfaces
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

if [ ! -f /var/spool/cron/crontabs/root ];then
   touch /var/spool/cron/crontabs/root
fi
if [ ! -d /opt/network/ ] && [ ! -f /usr/bin/internetsw ] ;then
  mkdir /opt/network/
  ln -s /opt/network/internetsw.sh /usr/bin/internet
fi  
cp /opt/websitemanager/network/internet.sh /opt/network/internet.sh && chmod +x /opt/network/internet.sh   
if ! grep -q -F /usr/bin/internet /var/spool/cron/crontabs/root; then
    (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/internet") | crontab -
fi

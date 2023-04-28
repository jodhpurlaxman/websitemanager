#!/bin/bash
OS=$(cat /etc/os-release | sed -n '1p' | awk -F "=" '{print $2}')
echo "Enter the Static IP : "  
read IP
/sbin/ip -4 -o a | cut -d ' ' -f 2,7 | cut -d '/' -f 1
if [ $? == 0 ]; then
  ETH0=enp3s0
  else
  echo "Enter the main ethernet adaptor name : "  
read ETH0
fi

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
mkdir /opt/network/ && cp /opt/websitemanager/network/internetsw.sh /opt/network/internetsw.sh && chmod +x /opt/network/internetsw.sh && ln -s /opt/network/internetsw.sh /usr/bin/internetsw  
if ! grep -Fxq "/opt/network/internetsw" /var/spool/cron/crontabs/root
then
    (crontab -l 2>/dev/null; echo "* * * * * /usr/bin/internetsw") | crontab -
fi

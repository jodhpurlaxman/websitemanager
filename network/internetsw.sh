#!/bin/bash

status1=$(ping -c1 1.1.1.1 | grep "1 received" | awk '{print $4$5}'| sed 's/\(.*\),/\1 /')
status2=$(ping -c1 8.8.8.8 | grep "1 received" | awk '{print $4$5}'| sed 's/\(.*\),/\1 /')
Current_GW=$(ip route | grep default | awk '{print $3}')
OS=$(cat /etc/os-release | sed -n '1p' | awk -F "=" '{print $2}')


if [ "$status1" != "1received" ]  && [ "$status2" != "1received" ]; then
		if [ "$OS" == '"Ubuntu"' ];then 
			if [ "$Current_GW" == "192.168.0.1" ]; then
			        echo "Current internet is 1(Ubuntu)"
				sed -i 's/\<192.168.0.1\>/192.168.0.2/g' /etc/netplan/01-netcfg.yaml
				netplan apply
			else
				echo "Current internet is 2(Ubuntu)"
				sed -i 's/\<192.168.0.2\>/192.168.0.1/g' /etc/netplan/01-netcfg.yaml
				netplan apply
			fi
		elif [ "$OS" != '"Ubuntu"' ]; then 
			if [ "$Current_GW" == "192.168.0.1" ]; then
				echo "Current internet is 1(Non-Ubuntu)"
				sed -i 's/\<192.168.0.1\>/192.168.0.2/g' /etc/network/interfaces
				ifdown etho && ifup eth0
			else
				echo "Current internet is 2(Non-Ubuntu)"
				sed -i 's/\<192.168.0.2\>/192.168.0.1/g' /etc/network/interfaces
				ifdown etho && ifup eth0
			fi
		fi
fi

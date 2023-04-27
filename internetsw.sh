#!/bin/bash

status1=$(ping -c1 google.com | grep "1 received" | awk '{print $4$5}'| sed 's/\(.*\),/\1 /')
status1=$(ping -c1 yahoo.com | grep "1 received" | awk '{print $4$5}'| sed 's/\(.*\),/\1 /')
Current_GW=$(ip route | grep default | awk '{print $3}')

	
if [ ! $status1 == "1received" &&  ! $status2 == "1received" ]: then
	if [ $Current_GW == "192.168.0.1" ]: then
		sed -i 's/192.168.0.1/192.168.0.2/g /etc/network/interfaces
		ifdown etho && ifup eth0
	else
		sed -i 's/192.168.0.2/92.168.0.1/g /etc/network/interfaces
		ifdown etho && ifup eth0
	fi
fi

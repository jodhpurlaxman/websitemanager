#!/bin/bash

function  status(){
dpkg -l | grep -q net-tools
chkpkg1=`echo $?`
dpkg -l | grep -q nmap
chkpkg2=`echo $?`
if [ ! $chkpkg1 == 0 ] && [ ! $chkpkg2 == 0 ]; then
        sudo apt install net-tools nmap
else
        echo "func_status_info: dependency already setisfied"
fi

MAC1=`arp -v 192.168.0.1 | awk '{print $3}' | sed -n '2 p'`
MAC2=`arp -v 192.168.0.2 | awk '{print $3}' | sed -n '2 p'`
test1=`sudo nping --icmp --dest-mac $MAC1 8.8.8.8 -c 2 | grep "Raw packets sent" | awk '{print $8}'`
test2=`sudo nping --icmp --dest-mac $MAC2 8.8.8.8 -c 2 | grep "Raw packets sent" | awk '{print $8}'`

if [ ! $test1 == 0 ] && [ ! $test1 == 0 ]; then
   echo "func_status_info: Both internet connections UP"
elif [ $test1 >= 0 ];then
   echo "func_status_info: Only internet connection1 is working"
elif [ $test2 >= 0 ]; then
   echo "func_status_info: Only internet connection2 is working"
fi
}


function change(){
    status1=$(ping -c1 1.1.1.1 | grep "1 received" | awk '{print $4$5}'| sed 's/\(.*\),/\1 /')
    status2=$(ping -c1 8.8.8.8 | grep "1 received" | awk '{print $4$5}'| sed 's/\(.*\),/\1 /')
    Current_GW=$(ip route | grep default | awk '{print $3}')
    OS=$(cat /etc/os-release | sed -n '1p' | awk -F "=" '{print $2}')


    if [ "$status1" != "1received " ] && [  "$status2" != "1received " ]; then
		if [ "$OS" == '"Ubuntu"' ];then 
			if [ "$Current_GW" == "192.168.0.1" ]; then
			        echo "Current internet is 1(Ubuntu), switching to 2"
				sed -i 's/\<192.168.0.1\>/192.168.0.2/g' /etc/netplan/01-netcfg.yaml
				sudo netplan apply
			else
				echo "Current internet is 2(Ubuntu), switching to 1"
				sed -i 's/\<192.168.0.2\>/192.168.0.1/g' /etc/netplan/01-netcfg.yaml
				sudo netplan apply
			fi
		elif [ "$OS" != '"Ubuntu"' ]; then 
			if [ "$Current_GW" == "192.168.0.1" ]; then
				echo "Current internet is 1(Non-Ubuntu), switching to 2"
				sed -i 's/\<192.168.0.1\>/192.168.0.2/g' /etc/network/interfaces
				sudo ifdown etho && sudo ifup eth0
			else
				echo "Current internet is 2(Non-Ubuntu), switching to 1"
				sed -i 's/\<192.168.0.2\>/192.168.0.1/g' /etc/network/interfaces
				sudo ifdown etho && sudo ifup eth0
			fi
		fi
    else 
    echo "info: current internet is UP, No need to change"
    
    echo "########################################################################" 
    echo "########################################################################"
    echo "=============   Would you like to switch to other internet   ==========="
    echo "==========================  Type y or n quickly  ======================="
    echo "########################################################################"
    echo "########################################################################"
    read -t 5 -n 1 answer
    if [ $answer == y ] || [ $answer == Y ]; then
        	if [ "$OS" == '"Ubuntu"' ];then 
			if [ "$Current_GW" == "192.168.0.1" ]; then
			        echo "Current internet is 1(Ubuntu), switching to 2"
				sed -i 's/\<192.168.0.1\>/192.168.0.2/g' /etc/netplan/01-netcfg.yaml
				sudo netplan apply
			else
				echo "Current internet is 2(Ubuntu), switching to 1"
				sed -i 's/\<192.168.0.2\>/192.168.0.1/g' /etc/netplan/01-netcfg.yaml
				sudo netplan apply
			fi
		elif [ "$OS" != '"Ubuntu"' ]; then 
			if [ "$Current_GW" == "192.168.0.1" ]; then
				echo "Current internet is 1(Non-Ubuntu), switching to 2"
				sed -i 's/\<192.168.0.1\>/192.168.0.2/g' /etc/network/interfaces
				sudo ifdown etho && sudo ifup eth0
			else
				echo "Current internet is 2(Non-Ubuntu), switching to 1"
				sed -i 's/\<192.168.0.2\>/192.168.0.1/g' /etc/network/interfaces
				sudo ifdown etho && sudo ifup eth0
			fi
		fi
    else
        echo "Can't wait anymore!, Bye"
    fi




    fi
}


if [ "$EUID" -ne 0 ]
      then echo-red "Please execute as root eg: sudo"
      echo-red "else contact server administrator"
      exit 1
else
    len=$#
    for val in $@
    do
        #echo $val
        $val
    done
fi



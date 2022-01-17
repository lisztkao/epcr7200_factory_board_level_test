#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi

if [ -n "$LOGFILE" ]; then
	echo "$TEST_NAME" > $LOGFILE
	echo "" >> $LOGFILE
	echo "$(date)" >> $LOGFILE
	echo "============================" >> $LOGFILE
fi
unset INTERACTIVE
	INTERACTIVE=1
	echo "Interactive Test $TEST_NAME"
	unset RESULT
RESULT=0
###=====================================================================
INTERFACE=$1
DHCP_TIMEOUT=$2
PING_TIMEOUT=$3
PING_IP=$4
	if [ -z "$INTERFACE" ]; then
		INTERFACE=eth0
	fi
	echo "INTERFACE:$INTERFACE"
	if [ -z "$DHCP_TIMEOUT" ]; then
		DHCP_TIMEOUT=0
	fi
	if [ "$PING_TIMEOUT" == "0" ]; then
		SKIPPINGTEST=1
	fi
	if ! ifconfig $INTERFACE down; then
		echo "Device $INTERFACE not found!"
		RESULT=1
	else
		echo "Device $INTERFACE down!"
	fi
	sleep 1
	if ! ifconfig $INTERFACE up; then
		echo "Device $INTERFACE not found!"
		RESULT=1
	else 
		echo "Device $INTERFACE up"
	fi
	sleep 20
	state=`cat /sys/class/net/$INTERFACE/operstate`

	if [ "$state" != "up" ]; then
		echo "$INTERFACE state not up! please check RJ45"
		RESULT=1
	fi
	if [ "$state" == "up" ]; then
		echo "$INTERFACE state up!"
		RESULT=0
	fi
	sleep 1
	if [ "$RESULT" == "0" ]; then
		read -p "Please input request DHCP yes=1 or no=0(enter to default:$DHCP_TIMEOUT): " NEW_DHCP
	fi
	if [ -z "$NEW_DHCP" ]; then
		echo "DHCP_TIMEOUT $DHCP_TIMEOUT"
	else
		DHCP_TIMEOUT=$NEW_DHCP
		echo "DHCP_TIMEOUT $DHCP_TIMEOUT"
	fi

	if [ "${DHCP_TIMEOUT}" != "0" ] && [ "${RESULT}" == "0" ]; then
		ps |grep "udhcpc -i $INTERFACE" |awk '{print $1;}' |xargs kill -9 &>/dev/null
		udhcpc -i $INTERFACE -t $DHCP_TIMEOUT -T 6 -n 2>&1 | tee temp_ping
		dhcp_ip=`cat temp_ping | grep for`
		echo "dhcp_ip:$dhcp_ip"
		if  [ -z "$dhcp_ip" ]; then
			echo "Could not get IP Address"
			RESULT=1
		else 
			echo "get IP Address"
		fi
	fi
	if [ "$RESULT" == "0" ]; then
		read -p "Please input PING_IP(enter to default:$PING_IP): " NEW_PING
	fi
	if [ -z "$NEW_PING" ]; then
			echo "PING_IP $PING_IP"
		else
			PING_IP=$NEW_PING
			echo "PING_IP $PING_IP"
	fi
	if [ "${SKIPPINGTEST}" != "1" ] && [ "${RESULT}" == "0" ]; then
		ping -I $INTERFACE $PING_IP -c $PING_TIMEOUT | grep %   | awk '/packet loss/{x=$6} END{print x}' 2>&1 | tee temp_ping
		ping_res=`cat temp_ping`
		if [ "$ping_res" == "0%" ]; then
			echo "ping $PING_IP  pass!"
		else
			echo "ping $PING_IP timeout loss:$ping_res"
			RESULT=1
		fi
	fi
	rm -f temp_ping

####======================================================================

if [ "$RESULT" == 0 ]; then
	if [ -n "$LOGFILE" ]; then
		echo "============================" >> $LOGFILE
		echo "SUCCESS" >> $LOGFILE
	fi
	if [ -n "$INTERACTIVE" ]; then
		echo -en "SUCCESS\n"
		echo ""
	else
		echo -en "SUCCESS\n"
	fi
else
	if [ -n "$LOGFILE" ]; then
		echo "============================" >> $LOGFILE
		echo "FAILURE" >> $LOGFILE
	fi
	if [ -n "$INTERACTIVE" ]; then
		echo -en "FAILURE\n"
		echo ""
	else
		echo -en "FAILURE\n"
	fi
fi
sleep 1
echo 7 > /proc/sys/kernel/printk


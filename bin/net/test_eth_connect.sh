#!/bin/sh

if [[ $2 == *.log ]]; then
	LOGFILE=$2
fi
INTERFACE="$1"
TEST_PARAMS=""
TEST_NAME="[Ethernet] - [Ethernet $INTERFACE]"


Turn_Off_Lan() {
	echo -e "\n===Close all ethernet interfaces==="
	for N in $NET_DEV_LIST; do
		ifconfig $N down
	done
}


Connect() {
	i=30
	if [ -z "`ifconfig -a | grep $INTERFACE`" ]; then
		echo -e "\n===No such $INTERFACE==="
		return 1 
	fi
	echo -e "\n===Start connecting network==="
	killall udhcpc
	ifconfig $INTERFACE up
	udhcpc -b -i $INTERFACE
	while [ -z "`ip route`" ];
	do
		echo "Waiting for connection( $i secs)"
                i=$(($i-1))
		sleep 1
		if [ "${i}" -eq 0 ];then
			echo "===Connection timeout==="
			return 1
		fi
	done
	return 0
}

Get_DNS_IP() {
	PATTERN='^[0-9]'
	DNS_IP=`cat /etc/resolv.conf | grep nameserver | head -n 1 | awk '{print $2}'`
	echo -e "\n===DNS IP is $DNS_IP==="
	if [ -z "$DNS_IP" ] || [[ ! "$DNS_IP" =~ $PATTERN ]]; then
		echo -e "\n===Not found DNS==="
		return 1
	fi
	return 0
}

Get_GATEWAY_IP() {
	PATTERN='^[0-9]'
	GATEWAY_IP=`ip route  | grep default | awk '{print $3}'`
	echo -e "\n===GATEWAY IP is $GATEWAY_IP==="
	if [ -z "$GATEWAY_IP" ] || [[ ! "$GATEWAY_IP" =~ $PATTERN ]]; then
		echo -e "\n===Not found GATEWAY IP==="
		return 1
	fi
	return 0
}

PING() {
	echo -e "\n===Start pinging $1==="
	LOSS_RATE="0%"
	ping -I $INTERFACE $1 -c 5 | tee /tmp/ping_log
	TEST_RESULT=`cat /tmp/ping_log | grep transmitted | awk '{print $6}'`
	if [ "$LOSS_RATE" != "$TEST_RESULT" ];then
		return 1
	fi
	return 0
}

function Test_Function
{
	RETVAL=0
	rm /etc/resolv.conf && sync
	systemctl stop connman
	if [ -n "$NET_DEV_LIST" ]; then
		Turn_Off_Lan
	fi
	
	Connect
	if [ "$?" -eq "1" ];then 
		RETVAL=1 
		return $RETVAL
	fi

	Get_GATEWAY_IP
	if [ "$?" -eq "0" ];then
		PING $GATEWAY_IP
	else
		Get_DNS_IP
		if [ "$?" -eq "0" ];then
			PING $DNS_IP
		else
			return 1 
		fi
	fi
	[ "$?" -eq "1" ] && RETVAL=1

	return $RETVAL	
}



if [ -n "$LOGFILE" ]; then
	echo "$TEST_NAME" > $LOGFILE
	echo "" >> $LOGFILE
	echo "$(date)" >> $LOGFILE
	echo "============================" >> $LOGFILE
fi
unset INTERACTIVE
if [ -n "$TEST_PROMPT_PRE" ]; then
	INTERACTIVE=1
	echo "Interactive Test $TEST_NAME"
	unset RESULT

	while [ -z "$RESULT" ]; do
		echo "   $TEST_PROMPT_PRE"

		if [ -z "$TEST_PROMPT_POST" ]; then
			echo -n "   Press any key to continue"
			read
            	else
                	sleep 2
            	fi

		#$TEST_COMMAND >> $LOGFILE 2>&1
		#RESULT=$?
		if [ -n "$LOGFILE" ]; then
			Test_Function $TEST_PARAMS >> $LOGFILE 2>&1
		else
			Test_Function $TEST_PARAMS
		fi
		RESULT=$?
		if [ -n "$TEST_PROMPT_POST" ]; then
			echo -n "   $TEST_PROMPT_POST (y/n/r[etry]): "
			read RESPONSE
			if [[ "$RESPONSE" == "y" ]]; then
				RESULT=0
			elif [[ "$RESPONSE" == "n" ]]; then
				RESULT=1
			else
				unset RESULT
			fi
            	fi
	done

	printf "%-60s: " "$TEST_NAME"
else
	if [ -n "$LOGFILE" ]; then
		printf "%-60s: " "$TEST_NAME"
		Test_Function $TEST_PARAMS $@ | tee -a $LOGFILE 2>&1
	else
		echo "Automated Test $TEST_NAME"
		echo ""
		Test_Function $TEST_PARAMS
	fi
	RESULT=${PIPESTATUS[0]}
fi
systemctl start connman
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


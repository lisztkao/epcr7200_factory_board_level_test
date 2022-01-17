#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[USB] - [USB DISK]"
TEST_PARAMS=""
SIZE=1024

check_usb_dev() {
	COUNT=0
	for device in /sys/block/*
	do
	    if udevadm info --query=property --path=$device | grep -q ^ID_BUS=usb
	    then
		echo $device | cut -d '/' -f 4
		COUNT=$(($COUNT+1))
	    fi
	done
	if [ "$COUNT" -lt "$USB_DEV_NUM" ];then
		return 1
	fi
}

check_USB2_0 () {
	PATTERN='^[3]'
	USB2_0_LIST=(`lsusb -t | grep "Bus" | grep 480M | awk '{print $3}'| cut -c 2`)	 #list which bus supports usb 2.0
	for N in ${USB2_0_LIST[@]};
	do
		USB_ID_LIST=(`lsusb -s $N: | grep -v -i 'hub' | awk '{print $6}'`)	#list usb disk ID on this bus
		if (( ! ${#USB_ID_LIST[@]} )); then					#there is no 2.0 disk on this bus
			echo "===(BUS $N) no usb disk==="
			#return 1
		fi
	done	
}
check_USB3_0 () {
	PATTERN='^[3]'
	USB3_0_LIST=(`lsusb -t | grep "Bus" | grep 5000M | awk '{print $3}'| cut -c 2`)	 #list which bus supports usb 3.0
	for N in ${USB3_0_LIST[@]};
	do
		USB_ID_LIST=(`lsusb -s $N: | grep -v -i 'hub' | awk '{print $6}'`)	#list usb disk ID on this bus
		if (( ! ${#USB_ID_LIST[@]} )); then					#there is no 3.0 disk on this bus
			echo "===(BUS $N) no usb disk==="
			#return 1
		fi
		for P in ${USB_ID_LIST[@]};						#test each usb disk support 3.0 or not	
		do
			if  [[ ! "`lsusb -v -s $N: | grep $P -A 4  | grep bcdUSB | awk '{print $2}'`" =~ $PATTERN ]]; then
				echo "===(BUS $N) ID:$P is not usb 3.0 device==="
				return 1
			fi
		done
	done
}

do_test () {
	RESULT=0	
	USBDEV="/dev/$1"

	if [ ! -e $USBDEV ]; then 
		echo "$USBDEV not exist"
		return 1
	fi

	dd if=/dev/urandom of=/tmp/data bs=1 count=$SIZE &>/dev/null
	echo ""
	echo -e "$USBDEV start testing"
	echo -ne "\t" "backing up..."
	dd if=$USBDEV of=/tmp/dataX bs=1 count=$SIZE &>/dev/null
	echo "done"
	
	echo -ne "\t" "writing $SIZE bytes data ..."
	dd if=/tmp/data of=$USBDEV bs=1 &>/dev/null
	echo "done"

	echo -ne "\t" "reading & comparing ..."
	dd if=$USBDEV of=/tmp/data_r bs=1 count=$SIZE &>/dev/null
	echo "done"

	if ! diff /tmp/data /tmp/data_r &>/dev/null; then
		echo "($1) : Read/Write"    "Failed"
		RESULT=1				
		rm /tmp/data*
		sync
		return $RESULT
	fi

	echo -ne "\t" "restoring ..."
	dd if=/tmp/dataX of=$USBDEV bs=1&>/dev/null
	echo "done"

	rm /tmp/data*
	sync
	return $RESULT
}

function Test_Function
{
	RETVAL=0
	echo ""
	check_USB2_0	
	if [ "$?" -eq "1" ];then
		return 1
	fi
	check_USB3_0	
	if [ "$?" -eq "1" ];then
		return 1
	fi
	USBDEVLIST=`check_usb_dev`
	if [ "$?" -eq "1" ];then
		echo "===USB disk is less than "$USB_DEV_NUM"==="
		return 1
	fi
	for N in $USBDEVLIST; do 
		do_test	$N
		if [ "$?" -eq "1" ];then
			return 1
		fi
	done
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


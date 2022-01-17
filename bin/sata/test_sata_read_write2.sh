#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[SATA] - [SATA DISK]"
TEST_PARAMS=""
SIZE=1024

check_sata_dev() {
	COUNT=0
	for device in /sys/block/*
	do
	    if udevadm info --query=property --path=$device | grep -q ^ID_BUS=ata
	    then
		echo $device | cut -d '/' -f 4
		COUNT=$(($COUNT+1))
	    fi
	done
	if [ "$COUNT" -lt "$SATA_DEV_NUM" ];then
		return 1
	fi
}

do_test () {
	RESULT=0	
	SATADEV="/dev/$1"

	if [ ! -e $SATADEV ]; then 
		echo "$SATADEV not exist"
		return 1
	fi

	dd if=/dev/urandom of=/tmp/data bs=1 count=$SIZE &>/dev/null
	echo ""
	echo -e "$SATADEV start testing"
	echo -ne "\t" "backing up..."
	dd if=$SATADEV of=/tmp/dataX bs=1 count=$SIZE &>/dev/null
	echo "done"
	
	echo -ne "\t" "writing $SIZE bytes data ..."
	dd if=/tmp/data of=$SATADEV bs=1 &>/dev/null
	echo "done"

	echo -ne "\t" "reading & comparing ..."
	dd if=$SATADEV of=/tmp/data_r bs=1 count=$SIZE &>/dev/null
	echo "done"

	if ! diff /tmp/data /tmp/data_r &>/dev/null; then
		echo "($1) : Read/Write"    "Failed"
		RESULT=1				
		rm /tmp/data*
		sync
		return $RESULT
	fi

	echo -ne "\t" "restoring ..."
	dd if=/tmp/dataX of=$SATADEV bs=1&>/dev/null
	echo "done"

	rm /tmp/data*
	sync
	return $RESULT
}

function Test_Function
{
	RETVAL=0
	echo ""
	SATADEVLIST=`check_sata_dev`
	if [ "$?" -eq "1" ];then
		echo "===SATA disk is less than "$SATA_DEV_NUM"==="
		return 1
	fi
	for N in $SATADEVLIST; do 
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


#!/bin/sh

if [[ $2 == *.log ]]; then
	LOGFILE=$2
fi
TEST_NAME="[CAN bus test] - [CAN bus]"
TEST_PARAMS=""
CAN_NUM=0
CAN_DATA=("123#11.22.33.44.55.66.77.88" "5A1#ABCDEF")
CAN_RESULT=("123   [8]  11 22 33 44 55 66 77 88" "5A1   [3]  AB CD EF")
CAN_TEST_RESULT=""

do_test_end() {
	killall cat
	for ((k=0; k<$CAN_NUM; k++)) ; do
		rm -f /tmp/log$k.txt
	done
	sync
}

verify_singel_canbus_data () {
	#First time: Can0 TX/RX. Second time: Can0 RX
        for ((i=0; i<2; i++)) ; do
		candump can0 > /tmp/log$i.txt & 1>/dev/null 2>/dev/null
		if [ 0 == "$i" ]; then
			cansend can0 ${CAN_DATA[$i]} 1>/dev/null 2>/dev/null
			sleep 1
		else
			sleep 5
		fi
		killall cat
		CAN_TEST_RESULT=$(cat /tmp/log$i.txt | tr -d '/r/n' | cut -c8-)

		if [ "${CAN_RESULT[$i]}" == "$CAN_TEST_RESULT" ]; then
			if [ 0 == "$i" ]; then
				echo "[tx:$i,rx:$i] Compare OK!"
			else
				echo "[tx:0,rx:$i] Compare OK!"
				echo "[tx:$i,rx:0] Compare OK!"
			fi
                else
			if [ 0 == "$i" ]; then
                                echo "[tx:$i,rx:$i] Compare FAIL!"
                        else
                                echo "[tx:0,rx:$i] Compare FAIL!"
                                echo "[tx:$i,rx:0] Compare FAIL!"
                        fi

			killall cat
			for ((k=0; k<2; k++)) ; do
				rm -f /tmp/log$k.txt
			done
			sync

                        return 1
                fi
	done

	killall cat
	for ((k=0; k<2; k++)) ; do
		rm -f /tmp/log$k.txt
	done
	sync
}

verify_data () {
	for ((i=0; i<$CAN_NUM; i++)) ; do
		candump can$i > /tmp/log$i.txt & 1>/dev/null 2>/dev/null
	done

	cansend can$1 ${CAN_DATA[$1]} 1>/dev/null 2>/dev/null

	for ((j=0; j<$CAN_NUM; j++)) ; do
		killall cat
		CAN_TEST_RESULT=$(cat /tmp/log$j.txt | tr -d '/r/n' | cut -c8-)
		
		if [ "${CAN_RESULT[$1]}" == "$CAN_TEST_RESULT" ]; then
			echo "[tx:$1,rx:$j] Compare OK!"
		else
			echo "[tx:$1,rx:$j] Compare FAIL!"
			do_test_end
			return 1
		fi
	done
	
	do_test_end
}

function Test_Function
{
	RETVAL=0
	
	if [ -n "$CAN0" ]; then
		CAN_NUM=1
		ip link set $CAN0 up type can bitrate 12500 1>/dev/null 2>/dev/null;ifconfig $CAN0 up
	fi
	
	if [ -n "$CAN1" ]; then
		CAN_NUM=2
		ip link set $CAN1 up type can bitrate 12500 1>/dev/null 2>/dev/null;ifconfig $CAN1 up
	fi
	
	if [ 0 == "$CAN_NUM" ]; then
		echo "No canbus config"
		return 1
	fi
	
	if [ 1 == "$CAN_NUM" ]; then
		verify_singel_canbus_data
		if [ "$?" -eq "1" ];then
			return 1
		fi
	else
		for ((N=0; N<$CAN_NUM; N++)) ; do
			verify_data $N
			if [ "$?" -eq "1" ];then
				return 1
			fi
		done
	fi
	
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
		Test_Function $TEST_PARAMS >> $LOGFILE 2>&1
	else
		echo "Automated Test $TEST_NAME"
		echo ""
		Test_Function $TEST_PARAMS
	fi
	RESULT=$?
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


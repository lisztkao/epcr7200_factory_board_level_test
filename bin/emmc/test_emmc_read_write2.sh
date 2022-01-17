#!/bin/sh

if [[ $2 == *.log ]]; then
	LOGFILE=$2
fi
TEST_NAME="[eMMC] - [eMMC Read\Write]"
TEST_PARAMS="$1"

SIZE=1024
declare -A mmc_type_group
for i in `ls /sys/bus/mmc/devices/`
do
        mmc_type_group[$i]=`cat /sys/bus/mmc/devices/$i/type`

done
return_emmc_dev() {
        for i in "${!mmc_type_group[@]}"
        do
                if [[ "${mmc_type_group[$i]}" == "MMC" ]];then
                        echo | ls /sys/bus/mmc/devices/$i/block/
                fi
        done
}
file_RW_test() {
	RESULT=0	
	dd if=/dev/urandom of=/tmp/data bs=1 count=$SIZE &>/dev/null

	echo -ne "\t" "backing up..."
	dd if=$emmcdev of=/tmp/dataX bs=1 count=$SIZE skip=4096 &>/dev/null
	echo "done"
	
	echo -ne "\t" "writing $SIZE bytes data ..."
	dd if=/tmp/data of=$emmcdev bs=1 seek=4096 &>/dev/null
	echo "done"

	echo -ne "\t" "reading & comparing ..."
	dd if=$emmcdev of=/tmp/data_r bs=1 count=$SIZE skip=4096 &>/dev/null

	if ! diff /tmp/data /tmp/data_r &>/dev/null; then
		echo "$2($1) : Read/Write"    "Failed"
		RESULT=1				
		rm /tmp/data*
		sync
		return $RESULT
	fi

	echo -ne "\t" "restoring ..."
	dd if=/tmp/dataX of=$emmcdev bs=1 seek=4096 &>/dev/null
	echo "done"

	rm /tmp/data*
	sync
	return $RESULT

}

function Test_Function
{
	RETVAL=0
	emmcdev=`return_emmc_dev`

#	partition_storage $emmcdev 
	

#	TEST_COUNT=$1
#	if [ -z "$TEST_COUNT" ]; then
#		TEST_COUNT=1
#	fi
	
	if [[ "$emmcdev" == mmcblk* ]];then
		file_RW_test ${emmcdev} "eMMC"
		if [ $? -ne 0 ]; then                                   
                	RETVAL=1                                        
                fi
	else
		echo "eMMC(no emmc)"    "Failed"
		RETVAL=1
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


#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[I2C EEPROM] - [I2C EEPROM]"
TEST_PARAMS=""
do_test () {
	RESULT=0	
	EEPROM="/sys/bus/i2c/devices/$1/eeprom"

	if [ ! -e $EEPROM ]; then 
		echo "$EEPROM not exist"
		return 1
	fi

	dd if=/dev/urandom of=/tmp/data bs=1 count=$2 &>/dev/null
	echo ""
	echo -e "$EEPROM start testing"
	echo -ne "\t" "backing up..."
	dd if=$EEPROM of=/tmp/dataX bs=1 count=$2 &>/dev/null
	echo "done"
	
	echo -ne "\t" "writing $2 bytes data ..."
	dd if=/tmp/data of=$EEPROM bs=1 &>/dev/null
	echo "done"

	echo -ne "\t" "reading & comparing ..."
	dd if=$EEPROM of=/tmp/data_r bs=1 count=$2 &>/dev/null
	echo "done"

	if ! diff /tmp/data /tmp/data_r &>/dev/null; then
		echo "($1) : Read/Write"    "Failed"
		RESULT=1				
		rm /tmp/data*
		sync
		return $RESULT
	fi

	echo -ne "\t" "restoring ..."
	dd if=/tmp/dataX of=$EEPROM bs=1&>/dev/null
	echo "done"

	rm /tmp/data*
	sync
	return $RESULT
}

function Test_Function
{
	RETVAL=0
	i=0
	j=0

        for M in $EEPROMLIST; do
		for N in $EEPROM_SIZE_LIST; do
			if [ "$i" -eq "$j" ]; then
                    		do_test $M $N
				if [ "$?" -eq "1" ]; then
					return 1
				fi
                	fi
			j=$(($j+1))
		done
		i=$(($i+1))
		j=0
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


#!/bin/sh


TEST_NAME="[Light Sensor] - [Light Sensor Read test]"

ENABLE_PATH=$1
ADC_PATH=$2

if [ -n "$LOGFILE" ]; then
	echo "$TEST_NAME" > $LOGFILE
	echo "" >> $LOGFILE
	echo "$(date)" >> $LOGFILE
	echo "============================" >> $LOGFILE
fi
unset INTERACTIVE
echo "ENABLE_PATH:$ENABLE_PATH"
echo "ADC_PATH:$ADC_PATH"

	if [[  -d "$ENABLE_PATH" ]]; then
		echo "Light Sensor detection failed!"
		RESULT=1
	else
		echo 0 > "$ENABLE_PATH"
		sleep 1
		echo 1 > "$ENABLE_PATH"
		sleep 1
		light_value=`cat $ADC_PATH`
		if [ $? -eq 0 ]; then
			echo "Light Sensor: $light_value"
			RESULT=0
		else
			echo "Light Sensor get value failed! "
			RESULT=1
		fi
		cat "$ENABLE_PATH"
		if [ $? -eq 0 ]; then
			echo "Light Sensor command OK!"
		else
			echo "Light Sensor command failed!"
			RESULT=1
		fi
		echo 0 > "$ENABLE_PATH"
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



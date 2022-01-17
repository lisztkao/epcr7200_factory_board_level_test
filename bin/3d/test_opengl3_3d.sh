#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $2 == *.log ]]; then
	LOGFILE=$2
fi
TEST_NAME="[3D] - [Show picture to 3D]"
TEST_PARAMS=$1
TEST_PROMPT_PRE="Look at the 3D picture"
TEST_PROMPT_POST="Did you see the picture on the display?"
 

if [ -n "$LOGFILE" ]; then
	echo "$TEST_NAME" > $LOGFILE
	echo "" >> $LOGFILE
	echo "$(date)" >> $LOGFILE
	echo "============================" >> $LOGFILE
fi
unset INTERACTIVE

export DISPLAY=:0
/usr/share/qt5/examples/opengl/hellogles3/hellogles3 &
sleep 3
echo -n "   $TEST_PROMPT_POST (y/n): "
read RESPONSE
if [[ "$RESPONSE" == "y" ]]; then
	RESULT=0
	elif [[ "$RESPONSE" == "n" ]]; then
	RESULT=1
else
	unset RESULT
fi

pid=` ps -l | grep hellogles3 | awk '/hellogles/{x=$4} END{print x}'`
kill $pid

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
echo 7 > /proc/sys/kernel/printk

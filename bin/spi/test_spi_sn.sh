#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[CONFIG] - [serial number write]"
#INTERFACE=$1
#LOGFILE_NEW=${LOGFILE}
#LOGFILE=${LOGFILE_NEW}

write_sn()
{
	W_DATA=`echo $WRITE_DATA`
	echo -ne $W_DATA | dd of=/dev/mtdblock0 bs=1 seek=$((0xd0006)) 2> /dev/null
}

read_sn()
{
	READ_DATA=`dd if=/dev/mtdblock0 bs=1 skip=$((0xd0006)) count=10 2> /dev/null | cut -c 1-10`	
}


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


		echo "For example: Q123456789"
		read -p "Please input serial number: " WRITE_DATA
PATTERN='^[A-Za-z0-9]{10}$'
		if [ -z "$WRITE_DATA"  ]; then
			echo "DATA is null"
			RESULT=1
		else
			if  [[ ! "$WRITE_DATA" =~ $PATTERN ]]; then
				echo "DATA is invalid"
				RESULT=1
			else
				echo "write data:$WRITE_DATA" >> $LOGFILE
				echo "write data:$WRITE_DATA"
				write_sn
				read_sn
				#echo "$WRITE_DATA" > "$INTERFACE"
				#READ_DATA=`cat $INTERFACE`
				echo "spi serial number:$READ_DATA"
				if [ "$WRITE_DATA" == "$READ_DATA" ]; then
					echo "write data  pass!"
				else
					echo "write data fail"
					RESULT=1
				fi
			fi
		fi


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


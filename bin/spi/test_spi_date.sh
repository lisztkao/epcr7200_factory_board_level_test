#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[CONFIG] - [manufacture date write]"
#INTERFACE=$1
#LOGFILE_NEW=${LOGFILE}
#LOGFILE=${LOGFILE_NEW}

write_date()
{
	W_DATA=`echo $WRITE_DATA | sed 's/-//g' | sed 's/_//g'`
	echo -ne $W_DATA | dd of=/dev/mtdblock0 bs=1 seek=$((0xd0010)) 2> /dev/null
}

read_date()
{
	READ_DATA=`dd if=/dev/mtdblock0 bs=1 skip=$((0xd0010)) count=14 2> /dev/null | cut -c 1-14`
	READ_DATA=`echo $READ_DATA | cut -c 1-4`-`echo $READ_DATA | cut -c 5-6`-`echo $READ_DATA | cut -c 7-8`_`echo $READ_DATA | cut -c 9-10`-`echo $READ_DATA | cut -c 11-12`-`echo $READ_DATA | cut -c 13-14`	
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


		echo "Format is  : YYYY-MM-DD_hh-mm-ss"
		echo "For example: 2019-02-11_06-00-30"
		read -p "Please input manufacture date: " WRITE_DATA
PATTERN='^[0-9]{4}([:-][0-9]{2}){2}[:_][0-9]{2}([:-][0-9]{2}){2}$'
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
				write_date
				read_date
				#echo "$WRITE_DATA" > "$INTERFACE"
				#READ_DATA=`cat $INTERFACE`
				echo "spi manufacture date:$READ_DATA"
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


#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[CONFIG] - [mac write]"
#INTERFACE=$1
#LOGFILE_NEW=${LOGFILE}
#LOGFILE=${LOGFILE_NEW}

write_mac()
{
	W_DATA=`echo $WRITE_DATA| sed 's/:/ /g'| tr [a-z] [A-Z]`
	sed -i "s/NODEID.*/NODEID = $W_DATA/g" bin/net/8119EF.cfg 
	pushd bin/net
	./rtnicpg-aarch64 /efuse /93c46
	popd
}

read_mac()
{
	pushd bin/net
	READ_DATA=`./rtnicpg-aarch64 /efuse /93c46 /r | grep NODEID | cut -c 11-27 | sed 's/ /:/g'| tr [A-Z] [a-z]`
	popd
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


		echo "For example: de:35:e3:67:5c:4d"
		read -p "Please input MAC address: " WRITE_DATA

PATTERN='^([0-9a-f]{2}[:-]){5}([0-9a-f]{2})$'
#PATTERN='^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$'
		if [ -z "$WRITE_DATA"  ]; then
			echo "DATA is null"
			RESULT=1
			#READ_DATA=`cat $INTERFACE`
			#echo "spi MAC:$READ_DATA"
		else
			if  [[ ! "$WRITE_DATA" =~ $PATTERN ]]; then
				echo "DATA is invalid"
				RESULT=1
			else
				echo "Remove RTL8169 driver"
				rmmod r8169
				echo "Install RTL8169 PG tool driver"
				modprobe pgdrv
				echo "write data:$WRITE_DATA" >> $LOGFILE
				echo "write data:$WRITE_DATA"
				write_mac
				read_mac
				echo "RTL8169 MAC:$READ_DATA"
				if [ "$WRITE_DATA" == "$READ_DATA" ]; then
					echo "write data  pass!"
				else
					echo "write data fail"
					RESULT=1
				fi
				rmmod pgdrv
				modprobe r8169
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


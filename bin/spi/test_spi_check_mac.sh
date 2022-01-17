#!/bin/sh

if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[SPI MAC] - [Check spi mac address]"
TEST_PARAMS="$1 $2"

RETVAL=0

function Test_Function
{
	RETVAL=0
    WRITE_DATA1=$1
	WRITE_DATA2=$2
	
	
	PATTERN='^([0-9a-f]{2}[:-]){5}([0-9a-f]{2})$'
	
	
	if [[ (-z "$WRITE_DATA1") || (-z "$WRITE_DATA2") ]]; then
			echo "DATA1/DATA2 is null"
			RETVAL=1
		else
			if  [[ ! "$WRITE_DATA1" =~ $PATTERN ]]; then
				echo "DATA1 is invalid"
				RETVAL=1
			elif  [[ ! "$WRITE_DATA2" =~ $PATTERN ]]; then
				echo "DATA2 is invalid"
				RETVAL=1	
			else
	
				spi_mtd2=`hexdump -C -n30 /dev/mtd2 | head -n 2 | awk '{print $18 $16}' | cut -c 2-17 | sed 'N;s/\n/ /'| sed -e 's/ //g' | sed 's/\,0x/:/g' | cut -c 3-19`
                spi_mtd3=`hexdump -C -n30 /dev/mtd3 | head -n 2 | awk '{print $18 $16}' | cut -c 2-17 | sed 'N;s/\n/ /'| sed -e 's/ //g' | sed 's/\,0x/:/g' | cut -c 3-19`

				echo spi_mtd2=$spi_mtd2
				echo spi_mtd3=$spi_mtd3
				
				shopt -s nocasematch
				case "$WRITE_DATA1" in
				 $spi_mtd2 ) echo "$WRITE_DATA1 $spi_mtd2 match";;
				 *) echo "$WRITE_DATA1 $spi_mtd2 no match"
					RETVAL=1;;
				esac
				
				case "$WRITE_DATA2" in
				 $spi_mtd3 ) echo "$WRITE_DATA2 $spi_mtd3 match";;
				 *) echo "$WRITE_DATA2 $spi_mtd3 no match"
					RETVAL=1;;
				esac
			fi
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


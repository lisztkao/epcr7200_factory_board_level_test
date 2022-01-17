#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[WIFI dbm] - [WIFI]"
 

INTERFACE=$1
AP_NAME=$2
AP_PASSWORD=$3
DBM_RANGE_HI=$4
DBM_RANGE_LOW=$5
PING_IP=$6
FCC_MODE=$7
KEY_MODE=$8
SCAN_COUNTER=$9

LOGFILE_NEW=${LOGFILE}"-"${AP_NAME}
LOGFILE=${LOGFILE_NEW}

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


	if [ "$AP_NAME" == "Linkou_RF" ]; then
		AP_NAME="Linkou RF"
	fi

	if [ -z "$INTERFACE" ]; then
	    INTERFACE=wlan0
	fi
	echo "INTERFACE:$INTERFACE"

	ifconfig $INTERFACE up
	
	sleep 2
	iw ${INTERFACE} disconnect
	if ! ifconfig $INTERFACE up; then
	    echo "Device $INTERFACE not found!"
	    RESULT=1
	else 
		echo "Device $INTERFACE up"
	fi
	sleep 1
	for((i=0;i<6;i++)) do
		ifconfig $INTERFACE | grep $INTERFACE > temp_status
		status_res=`cat temp_status`
		if [ -z "$status_res" ]; then
			echo "."
		else
			break
		fi
		if [ "$i" == "5" ]; then
			RESULT=1
			echo "can't set up"
		fi
		sleep 1
	done
	rm -f temp_status

	state=` ifconfig $INTERFACE | grep $INTERFACE | awk '/wlan/{x=$1} END{print x}'`
	if [ "$state" != "$INTERFACE" ]; then
	    echo "$INTERFACE state not up! please check wifi"
	    RESULT=1
	else 
	    echo "$INTERFACE state up!"
	    RESULT=0
	fi
	

	if [  -z "$AP_NAME"  ]; then
	    AP_NAME="android_test"
	fi
	
	if [ "$RESULT" == "0" ]; then
		read -p "Please input ap name. (enter to default:$AP_NAME): " NEW_AP
		if [ -z "$NEW_AP" ]; then
			echo "AP_NAME $AP_NAME"
		else
			AP_NAME=$NEW_AP
			echo "AP_NAME $AP_NAME"
		fi

		read -p "Please input ap password. (enter to default:$AP_PASSWORD ,null without password): " NEW_PASSWORD
		if [ -z "$NEW_PASSWORD" ]; then
			echo "AP_PASSWORD $AP_PASSWORD"
			if [ "$AP_PASSWORD" == "null" ]; then
				AP_PASSWORD=""
			fi
		elif [ "$NEW_PASSWORD" == "null" ]; then
			echo "without PASSWORD "
			 AP_PASSWORD=""
		else
			AP_PASSWORD=$NEW_PASSWORD
			echo "AP_PASSWORD $AP_PASSWORD"
		fi
	fi

		sleep 1
		for((i=0;i<$SCAN_COUNTER;i++)) do
			iw wlan0 scan | grep "$AP_NAME" > temp_scan
			scan_res=`cat temp_scan`
			if [ -z "$scan_res" ]; then
				RESULT=1
				echo "scan..."
			else
				RESULT=0
				echo "scan find $AP_NAME"
				break
			fi
			if [ "$i" == "9" ]; then
				RESULT=1
				echo "cannot find $AP_NAME"
			fi
			sleep 1
		done
		# rm -f temp_scan

	if [ "$RESULT" != "1" ]; then
		if [ -z "$AP_PASSWORD" ]; then
			killall wpa_supplicant &>/dev/null
			sleep 2
			iw $INTERFACE connect  "$AP_NAME"
			echo "iw connecting"
		else
			###iw $INTERFACE connect  $AP_NAME key d:0:$AP_PASSWORD
			killall wpa_supplicant &>/dev/null
			sleep 2

			read -p "Please input ap password.(WEP or WPA) (enter to default:$KEY_MODE)" NEW_KEY_MODE
			if [ -z "$NEW_KEY_MODE" ]; then
				echo "KEY_MODE $KEY_MODE"
			else
				if [ "$NEW_KEY_MODE" == "WEP" ]; then
					KEY_MODE="WEP"
				else
					KEY_MODE="WPA"
				fi
				echo "KEY_MODE $KEY_MODE"
			fi

			if [ "$KEY_MODE" == "WPA" ]; then
				wpa_passphrase "$AP_NAME" $AP_PASSWORD > /tmp/wpa.conf
				wpa_supplicant -Dnl80211 -c/tmp/wpa.conf -i $INTERFACE -B
			fi
			if [ "$KEY_MODE" == "WEP" ]; then
				iw dev wlan0 connect "$AP_NAME" key d:0:$AP_PASSWORD
			fi

			echo "wpa_supplicant connecting"
		fi
		sleep 3
		
		for((i=0;i<8;i++)) do
			iw $INTERFACE link | grep "$AP_NAME" > temp_link
			link_res=`cat temp_link`
			if [ -z "$link_res" ]; then
				echo "."
			else
				break
			fi
			if [ "$i" == "7" ]; then
				RESULT=1
				echo "can't connect"
			fi
			sleep 1
		done
		rm -f temp_link

		if [ "$RESULT" != "1" ]; then
			if [ "$DBM_RANGE_LOW" != "0" ]; then
				###echo "DBM_RANGE_HI:$DBM_RANGE_HI"
				###echo "DBM_RANGE_LOW:$DBM_RANGE_LOW"
				read -p "Please input dbm threshold (enter to default:$DBM_RANGE_LOW): " NEW_DBM_RANGE
				if [ -z "$NEW_DBM_RANGE" ]; then
					echo "dbm threshold $DBM_RANGE_LOW"
				else
					DBM_RANGE_LOW=$NEW_DBM_RANGE
					echo "dbm threshold $DBM_RANGE_LOW"
				fi

				for((i=0;i<10;i++)) do
					iw $INTERFACE link | grep dBm | awk '/dBm/{x=$2} END{print x}' > temp_rssi
					rssi_res=`cat temp_rssi`
					echo "signal:$rssi_res dbm "
					level[$i]=$rssi_res
				done
				level_sum=0
				for (( i=0;i<10;i++ ))
				do
					level_sum=`expr ${level[$i]} + $level_sum`
				done
				level_ave=`expr $level_sum / 10`
				if [[ $level_ave -lt $DBM_RANGE_HI ]] && [[ $level_ave -gt $DBM_RANGE_LOW ]];then
				###if[ [ $level_ave -gt $DBM_RANGE_LOW ] || [ $level_ave -lt $DBM_RANGE_HI ] ]; then
						echo "signal:$level_ave dbm pass"
						echo "signal:$level_ave dbm pass" >> $LOGFILE
					else
						echo "signal:$level_ave dbm fail"
						echo "signal:$level_ave dbm fail" >> $LOGFILE
						RESULT=1
				fi
				rm -f temp_rssi
			fi
		fi
	fi


###============================================================================
	sleep 2
	if [ "$RESULT" != "1" ] ; then
		if [ "$PING_IP" != "0.0.0.0" ] ; then

			if ! udhcpc -i $INTERFACE -t 3 -T 3 -n ; then
			echo "Could not get IP Address from $NETWORK"
			killall wpa_supplicant &>/dev/null
			rm /tmp/wpa.conf
			RESULT=1
			fi

			if [ "$RESULT" != "1" ] ; then
				read -p "Please input IP address for ping test (enter to default:$PING_IP): " NEW_PING
				if [ -z "$NEW_PING" ]; then
					echo "PING_IP $PING_IP"
				else
					PING_IP=$NEW_PING
					echo "PING_IP $PING_IP"
				fi
				ping -I $INTERFACE $PING_IP -c 5 | grep 100%  > temp_ping

				ping_res=`cat temp_ping`
				if [ -z "$ping_res" ]; then
					echo "ping $PING_IP  pass!"
					echo "ping $PING_IP  pass!" >> $LOGFILE
				else
					echo "ping $PING_IP timeout loss:$ping_res"
					echo "ping $PING_IP timeout loss:$ping_res" >> $LOGFILE
					RESULT=1
				fi
				rm -f temp_ping
			fi
		fi
	fi
###==========================================================================


	if [ "$RESULT" != "1" ]; then
		if [ "$FCC_MODE" != "0x0" ]; then

			read -p "Please input country code (enter to default:FCC)" CODE_MODE
			if [ -z "$CODE_MODE" ]; then
				FCC_MODE="0x10"
			else
				if [ "$CODE_MODE" == "FCC" ]; then
					FCC_MODE="0x10"
				fi
				if [ "$CODE_MODE" == "JP" ]; then
					FCC_MODE="0x40"
				fi
				if [ "$CODE_MODE" == "ETSI" ]; then
					FCC_MODE="0x30"
				fi
				if [ "$CODE_MODE" == "WW" ]; then
					FCC_MODE="0xff"
				fi
			fi

			fcc_res=`cat /sys/kernel/debug/ieee80211/phy0/mwlwifi/info  | grep  region | awk '/region/{x=$4} END{print x}'`
			if [ "$fcc_res" == "$FCC_MODE" ]; then
				echo "$CODE_MODE code:$fcc_res   pass!"
				echo "$CODE_MODE code:$fcc_res   pass!" >> $LOGFILE
			else
				echo "$CODE_MODE code:$fcc_res   fail"
				echo "$CODE_MODE code:$fcc_res   fail" >> $LOGFILE
				RESULT=1
			fi
		fi
	fi
	
	
####======================================================================
 

if [ "$RESULT" == "0" ]; then
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
		echo   "FAILURE" 
	else
		echo   "FAILURE"
	fi
fi
 
echo 7 > /proc/sys/kernel/printk


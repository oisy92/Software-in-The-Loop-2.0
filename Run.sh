#!/bin/bash
chmod +x ~/ardupilot/ArduCopter/tests.sh
Dseconds=1
Limit=10


T=$(stat -c %x ~/ArduPilot_Logs | cut -d" " -f 2)
export T="${T::-10}"
Seconds=$((${Time[0]}*3600 + ${Time[1]}*60 + ${Time[2]}))
IFS="$SavedIFS"
HSeconds=$(($Seconds+1))
export Check=$(($Seconds + $Limit))
SavedIFS="$IFS"
IFS=":"
Time=($T)



#~/ardupilot/ArduCopter/tests.sh &




while true; do

	export Check=$(($Seconds + $Limit))
	sleep 1
	echo CURRENT $Seconds
	echo LIMIT $Check
	echo HISTORICAL $HSeconds
	Seconds=$(($Seconds + $Dseconds))

	if [[ $Seconds -ne $HSeconds ]]; then

		echo FILE HAS CHANGED

		T=$(stat -c %x ~/ArduPilot_Logs | cut -d" " -f 2)
		export T="${T::-10}"
		SavedIFS="$IFS"
		IFS=":"
		Time=($T)
		Seconds=$((${Time[0]}*3600 + ${Time[1]}*60 + ${Time[2]}))
		IFS="$SavedIFS"
		HSeconds=$(($Seconds+1))
		export Check=$(($Seconds + $Limit))
		SavedIFS="$IFS"
		IFS=":"
		#Seconds=$(($Seconds + $Dseconds))
	fi


	if [[ $Seconds > $Check ]]; then

		echo im here
		pkill tests
		pkill arducopter
		pkill xterm
		disown -a
		sleep 10
		T=$(stat -c %x ~/ArduPilot_Logs | cut -d" " -f 2)
		export T="${T::-10}"
		SavedIFS="$IFS"
		IFS=":"
		Time=($T)
		Seconds=$((${Time[0]}*3600 + ${Time[1]}*60 + ${Time[2]}))
		IFS="$SavedIFS"
		HSeconds=$(($Seconds+1))
		export Check=$(($Seconds + $Limit))


		#~/ardupilot/ArduCopter/tests.sh &
		fi

done







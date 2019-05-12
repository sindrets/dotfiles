#!/bin/bash

notif_id=1559176921

# get the most relevant sink
sink=`pactl list short sinks | grep RUNNING | cut -f1`
if [ -z "$sink" ]; then
	sink=`pacmd info | grep "Default sink" | awk '{print $4}'`
fi

case "$1" in
	--inc)
		volume=`pamixer --sink $sink --get-volume-human`
		rounded=`awk '{print int( ($1+2) / 5) * 5 + 5 "%"}' <<< $volume`
		pactl set-sink-volume $sink "$rounded"
		dunstify -r $notif_id "Volume $(pamixer --sink $sink --get-volume-human)" -t 1000 -i audio-volume-high
		;;
	--dec)
		volume=`pamixer --sink $sink --get-volume-human`
		rounded=`awk '{print int( ($1+2) / 5) * 5 - 5 "%"}' <<< $volume`
		pactl set-sink-volume $sink "$rounded"
		dunstify -r $notif_id "Volume $(pamixer --sink $sink --get-volume-human)" -t 1000 -i audio-volume-low
		;;
	--mute)
		/usr/bin/pamixer --sink $sink -t

		isMute=$(pamixer --sink $sink --get-mute)
		if [ "$isMute" == "true" ]; then
			dunstify -r $notif_id "Volume muted" -t 1000 -i audio-volume-muted-blocked-panel;
		else 
			dunstify -r $notif_id "Volume unmuted" -t 1000 -i audio-volume-medium
		fi
		;;
esac


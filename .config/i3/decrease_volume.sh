#!/bin/sh

# Get most relevant sink
sink=`pactl list short sinks | grep RUNNING | cut -f1`
sLength=`expr length "$sink"`
if [ $sLength -eq 0 ]; then
	sink=`pacmd info | grep "Default sink" | awk '{print $4}'`
fi

# Round to nearest 5 to satisfy my autism
volume=`pamixer --sink $sink --get-volume-human`
rounded=`awk '{print int( ($1+2) / 5) * 5 - 5 "%"}' <<< $volume`

/usr/bin/pactl set-sink-volume $sink "$rounded"
notify-send "🔉 Volume $(pamixer --sink $sink --get-volume-human)" -t 1000

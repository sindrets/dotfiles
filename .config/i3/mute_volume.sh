#!/bin/sh

# Get the most relevant sink
sink=`pactl list short sinks | grep RUNNING | cut -f1`
sLength=`expr length "$sink"`
if [ $sLength -eq 0 ]; then
	sink=`pacmd info | grep "Default sink" | awk '{print $4}'`
fi

/usr/bin/pamixer --sink $sink -t

isMute=$(pamixer --sink $sink --get-mute)
if [ "$isMute" == "true" ]; then
	notify-send "🔇 Volume muted" -t 1000;
else 
	notify-send "🔈 Volume unmuted" -t 1000
fi

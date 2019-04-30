#!/bin/sh
sink=`pactl list short sinks | grep RUNNING | cut -f1`
sLength=`expr length "$sink"`
[ $sLength -eq 0  ] && sink=0
isMute=$(pamixer --sink $sink --get-mute)
if [ "$isMute" == "true" ]; then
	notify-send "Volume unmuted" -t 500;
else 
	notify-send "Volume muted" -t 500
fi
/usr/bin/pamixer --sink $sink -t

#!/bin/sh
sink=`pactl list short sinks | grep RUNNING | cut -f1`
sLength=`expr length "$sink"`
[ $sLength -eq 0 ] && sink=0
notify-send "Volume $(pamixer --sink $sink --get-volume-human)" -t 500
/usr/bin/pactl set-sink-volume $sink '+5%'

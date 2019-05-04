#!/bin/bash

backlight=/sys/class/backlight/intel_backlight/brightness
max=`cat /sys/class/backlight/intel_backlight/max_brightness`
min=`perl -e "use POSIX; print ceil($max / 100)"`
step="$[ ($max - $min) / 20 ]"

#echo "max: $max"
#echo "min: $min"
#echo "step: $step"

modValue () {
	local result=`cat /sys/class/backlight/intel_backlight/brightness`
	result="$[ $result + $1 ]"
	[ $result -gt $max ] && result=$max
	[ $result -lt $min ] && result=$min
	echo $result
}

currentPercent () {
	current=`cat $backlight`
	perl -e "use POSIX; print floor( (($current - $min) / ($max - $min) * 100) + 0.5 )"
}

case $1 in
	inc)
		# increase
		echo `modValue $step` > $backlight
		notify-send "Brightness: $(currentPercent)%" -t 1000 -i notification-display-brightness-high
		;;
	dec)
		# decrease
		echo `modValue -$step` > $backlight
		notify-send "Brightness: $(currentPercent)%" -t 1000 -i notification-display-brightness-low
		;;
	get)
		# return current percent
		echo `currentPercent`
		;;
esac




#!/bin/bash

notif_id="$($HOME/.config/scripts/int-hash.sh $(realpath -m $0))"

backlight=/sys/class/backlight/intel_backlight/brightness
max=`cat /sys/class/backlight/intel_backlight/max_brightness`
min=`perl -e "use POSIX; print ceil($max / 100)"`
nSteps=20
step="$[ $max / $nSteps ]"

#echo "max: $max"
#echo "min: $min"
#echo "step: $step"

modValue () {
	local result=`cat /sys/class/backlight/intel_backlight/brightness`
	result="$[ $result + $1 ]"
	# round to closest step % of max
	pStep=$[ 100 / $nSteps ]
	result=`perl -e \
		"use POSIX;
		print floor( floor( ($result / $max * 100 + ($pStep / 2)) / $pStep) * $pStep * $max / 100 )"`
	[ $result -gt $max ] && result=$max
	[ $result -lt $min ] && result=$min
	echo $result
}

currentPercent () {
	current=`cat $backlight`
	perl -e "use POSIX; print floor( ($current / $max * 100) + 0.5 )"
}

case $1 in
	--inc)
		# increase
		echo `modValue $step` > $backlight
		dunstify -r "$notif_id" "Brightness: $(currentPercent)%" -t 1000 -i notification-display-brightness-high
		echo `currentPercent`
		;;
	--dec)
		# decrease
		echo `modValue -$step` > $backlight
		dunstify -r "$notif_id" "Brightness: $(currentPercent)%" -t 1000 -i notification-display-brightness-low
		echo `currentPercent`
		;;
	--get)
		# return current percent
		echo `currentPercent`
		;;
esac

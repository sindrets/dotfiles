#!/usr/bin/bash

notif_id="$($HOME/.config/scripts/int-hash.sh $(realpath -m $0))"

notify() {
	local icon="${2:-'notification-display-brightness-high'}"
	echo "$1" > /dev/stderr
	dunstify -r "$notif_id" "$1" -t 1000 -i $icon
}

if [[ -e "/sys/class/backlight/intel_backlight" ]]; then
	backlight=/sys/class/backlight/intel_backlight
elif [[ -e "/sys/class/backlight/nvidia_0" ]]; then
	backlight=/sys/class/backlight/nvidia_0
else
	notify "Couldn't find backlight!"
	exit 1
fi

brightness_file="$backlight/brightness"
max=`cat $backlight/max_brightness`
min=`perl -e "use POSIX; print ceil($max / 100)"`
nSteps=20
step="$[ $max / $nSteps ]"

#echo "max: $max"
#echo "min: $min"
#echo "step: $step"

modValue () {
	local result=`cat $brightness_file`
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
	current=`cat $brightness_file`
	perl -e "use POSIX; print floor( ($current / $max * 100) + 0.5 )"
}

case $1 in
	--inc)
		# increase
		echo `modValue $step` > $brightness_file
		notify "Brightness: $(currentPercent)%" notification-display-brightness-high
		echo `currentPercent`
		;;
	--dec)
		# decrease
		echo `modValue -$step` > $brightness_file
		notify "Brightness: $(currentPercent)%" notification-display-brightness-low
		echo `currentPercent`
		;;
	--get)
		# return current percent
		echo `currentPercent`
		;;
esac

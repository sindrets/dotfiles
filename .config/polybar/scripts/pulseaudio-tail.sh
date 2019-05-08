#!/bin/sh

volume=0
muted=false
sink=0

# Get the most relevant sink
update_sink() {	
	sink=`pactl list short sinks | grep RUNNING | cut -f1`
	if [ -z "$sink" ]; then
		sink=`pacmd info | grep "Default sink" | awk '{print $4}'`
	fi
}

volume_up() {
    update_sink
    pactl set-sink-volume "$sink" +1%
}

volume_down() {
    update_sink
    pactl set-sink-volume "$sink" -1%
}

volume_mute() {
    update_sink
    pactl set-sink-mute "$sink" toggle
}

volume_print() {
    update_sink

	active_port=$(pacmd list-sinks | sed -n "/index: $sink/,/index:/p")
	if [ -z "$active_port" ]; then
		active_port=`pacmd list-sinks | sed -n "/name: <$sink/,/index:/p"`
	fi
	active_port=`echo "$active_port" | grep "active port"`

    if echo "$active_port" | grep -q speaker; then
        # icon=""
		icon=""
    elif echo "$active_port" | grep -Pq "headphones|lineout"; then
        icon=""
    else
        icon=""
    fi

    muted=$(pamixer --sink "$sink" --get-mute)

    if [ "$muted" = true ]; then
        echo "$icon --"
    else
		volume=`pamixer --sink "$sink" --get-volume`
        echo "$icon $volume"
    fi
}

update_volume () {
	volume=`pamixer --sink "$sink" --get-volume`
	muted=`pamixer --sink "$sink" --get-mute`
}

listen() {
    volume_print

	local vLast=$volume
	local mLast=$muted
	local sLast=$sink
    pactl subscribe | while read -r event; do
	if echo "$event" | grep -Pq "('change' on sink)|('new' on source-output)"; then
			update_volume
			update_sink
			if [ "$volume" != "$vLast" ] || [ "$muted" != "$mLast"  ] || [ "$sink" != "$sLast" ]; then 
				vLast=$volume
				mLast=$muted
				sLast=$sink
				volume_print
			fi
        fi
    done
}

case "$1" in
    --up)
        volume_up
        ;;
    --down)
        volume_down
        ;;
    --mute)
        volume_mute
        ;;
    *)
        listen
        ;;
esac

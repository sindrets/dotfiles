#!/bin/sh

volume=0

# Get the most relevant sink
update_sink() {	
    sink=`pactl list short sinks | grep RUNNING | cut -f1`
	if [ `expr length "$sink"` -eq 0 ]; then
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
	if [ `expr length "$active_port"` -eq 0 ]; then
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
		volume=0
        echo "$icon --"
    else
		volume=`pamixer --sink "$sink" --get-volume`
        echo "$icon $volume"
    fi
}

update_volume () {
	volume=`pamixer --sink "$sink" --get-volume`
}

listen() {
    volume_print

	local now=$volume
	local last=$volume
    pactl subscribe | while read -r event; do
        if echo "$event" | grep -q "'change' on sink"; then
			update_volume
            now=$volume
			if [ $now != $last ]; then 
				last=$now
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

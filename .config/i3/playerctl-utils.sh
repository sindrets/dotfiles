#!/bin/bash 

icon_playing=""
icon_paused=""

player=""
interval_rate="medium"
path_last_player="/tmp/PU_LAST_PLAYER"
metadata=""

format_index=1
format_list=(
	"__STATUS__ __PLAYER__: __ARTIST__ - __TITLE__ __POSITION__|__DURATION__"
	"__STATUS__ __PLAYER__: __ARTIST__ - __TITLE__ | __DURATION__"
	"__STATUS__ __PLAYER__: __TITLE__"
	"__STATUS__ __PLAYER__"
	"__STATUS__"
)

cycle_formats () {
	format_index=$[ ($format_index + 1) % ${#format_list[@]} ]
}

# get the most relevant player
update_player () {
	
	local n=`playerctl -a status 2>/dev/null | grep -m 1 -ni playing | cut -d : -f 1`
	
	if [ -z "$n" ]; then 
		if [ -e "$path_last_player" ] && [ -n "`cat \"$path_last_player\"`" ]; then
			player=`cat "$path_last_player"`
		elif [ -z "$player" ]; then
			player=`playerctl -l | sed -n "1p"`
		fi
	else 
		player=`playerctl -l | sed -n "$n p"`
	fi

	printf "$player" > "$path_last_player"

}

# nanoseconds to duration string
duration () {

	local n=`echo $1 | cut -d . -f1` # remove decimal point
	local t=$[ $n / 1000000 ]
	
	local h=$[ $t / 3600 ]
	local m=$[ ($t % 3600) / 60 ]
	local s=$[ $t % 60 ]

	if [ $h -eq 0 ]; then
		printf "%02d:%02d\n" $m $s
	else
		printf "%02d:%02d:%02d\n" $h $m $s
	fi

}

update_metadata () {

	local t=`playerctl -p "$player" metadata mpris:length 2>/dev/null`
	[ -n "$t" ] && t=`duration "$t"`

	metadata=$(printf "`playerctl -p "$player" metadata --format "__{{ uc(status) }}__\n{{ playerName }}\n{{ artist }}\n{{ title }}\n{{ duration(position) }}\n__DURATION__\n" 2>/dev/null`")
	metadata="${metadata/__PLAYING__/$icon_playing}"
	metadata="${metadata/__PAUSED__/$icon_paused}"
	metadata="${metadata/__DURATION__/$t}"

}

# Retrieve metadata.
# @param {int} line number
data () {
	echo -n "$metadata" | sed -n "$1 p"
}

player_tail () {	

	update_metadata
	local format=""
	local rate=`echo "${@}" | grep -Po "((?:\s|^)--interval-rate\s*\S*)" | awk '{print $2}'`
	local index=`echo "${@}" | grep -Po "((?:\s|^)(?:--format-index|-i)\s*\S*)" | awk '{print $2}'`
	[ -n "$rate" ] && interval_rate=$rate
	[ -n "$index" ] && format_index=$index

	# the interval format is only used to control how often iformation is polled
	case $interval_rate in
		high)
			format="{{ status }} {{ playerName }} {{ title }} {{ position }}"
			;;
		medium)
			format="{{ status }} {{ playerName }} {{ title }}"
			;;
		low)
			format="{{ playerName }} {{ title }}"
			;;
	esac

	playerctl -a metadata --format "$format" --follow 2>/dev/null | while read -r line ; do

		trap cycle_formats USR1

		[ ! `echo "$line" | awk '{print $2}' | cut -d : -f1 | grep -q "$player"` ] && update_player

		update_metadata
		local result="${format_list[$format_index]}"

		result="${result/__STATUS__/`data 1`}"
		result="${result/__PLAYER__/`data 2`}"
		result="${result/__ARTIST__/`data 3`}"
		result="${result/__TITLE__/`data 4`}"
		result="${result/__POSITION__/`data 5`}"
		result="${result/__DURATION__/`data 6`}"

		echo "$result"

	done

}

case "$1" in 

	--active)
		update_player
		echo $player
		;;

	--use-active)
		update_player
		playerctl -p "$player" "${@:2}"
		;;

	--tail)
		update_player
		player_tail ${@:2}
		;;

esac


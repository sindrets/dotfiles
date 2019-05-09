#!/bin/bash 

icon_playing=""
icon_paused=""

player=""
interval_rate="high"
path_last_player="/tmp/PU_LAST_PLAYER"

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

player_tail () {
	
	local format=""
	local rate=`echo "${@}" | grep -Po "(--interval-rate\s*\S*)" | awk '{print $2}'`
	[ -n "$rate" ] && interval_rate=$rate

	case $interval_rate in
		high)
			format="__{{ uc(status) }}__ {{ playerName }}: {{ artist }} - {{ title }} {{ duration(position) }}|__DURATION__"
			;;
		medium)
			format="__{{ uc(status) }}__ {{ playerName }}: {{ artist }} - {{ title }} | __DURATION__"
			;;
		low)
			format="{{ playerName }}: {{ artist }} - {{ title }} | __DURATION__"
			;;
	esac

	playerctl -a metadata --format "$format" --follow | while read -r line ; do
		[ ! `echo "$line" | awk '{print $2}' | cut -d : -f1 | grep -q "$player"` ] && update_player
		local t=`playerctl -p "$player" metadata mpris:length 2>/dev/null`

		[ -n "$t" ] && t=`duration "$t"`
		line="${line/__DURATION__/$t}"
		line="${line/__PLAYING__/$icon_playing}"
		line="${line/__PAUSED__/$icon_paused}"
		echo $line
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


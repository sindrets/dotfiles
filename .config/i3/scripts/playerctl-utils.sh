#!/usr/bin/env bash

# --- CONFIGURABLE VARS: ---
icon_playing=""							# Will replace the status token when music is playing
icon_paused=""								# Will replace the status token when music is paused
interval_rate="medium"						# {low/medium/high} Controls how often information is polled during --follow
path_last_player="/tmp/PU_LAST_PLAYER"		# A file that will be used to keep track of the last used player
title_max_length=25							# The max length of the title string. If longer will be shortened with ellipsis
template_index=0							# Determines the initial format template

# A list of templates that will be used to format the output of the --follow command.
# The available tokens are:
# __STATUS__, __PLAYER__, __ARTIST__, __ALBUM__, __TITLE__, __TRACK_NUMBER__, __POSITION__, __DURATION__
# The __POSITION__ token requires 'high' interval_rate to be useful.
templates=(
	"__STATUS__ __PLAYER__: __ARTIST__ - __TITLE__ | __DURATION__"
	"__STATUS__ __PLAYER__: __TITLE__ | __DURATION__"
	"__STATUS__ __PLAYER__: __TITLE__"
	"__STATUS__ __PLAYER__ | __DURATION__"
	"__STATUS__ __PLAYER__"
	"__STATUS__"
)

# A list of regex patterns for players you want to ignore.
ignore_players=(
	"chromium.*"
)
# --------------------------


player=""
metadata=""

# ensure that the process doesn't terminate upon receiving SIGUSR1
trap "" USR1

cycle_templates () {
	template_index=$[ ($template_index + 1) % ${#templates[@]} ]
}

# Returns all players with ignored players excluded
list_players () {
	
	local format="{{ playerName }} {{ status }}"
	local all_players="`playerctl -a metadata -f "$format" 2> /dev/null`"
	for pattern in "${ignore_players[@]}"; do
		all_players="`echo "$all_players" | sed "/$pattern/d"`"
	done

	echo "$all_players"

}

# get the most relevant player
update_player () {

	local all_players="`list_players`"

	if [ -z "$all_players" ]; then
		rm "$path_last_player" 2>/dev/null
		player=""
		return
	fi

	player=`echo "$all_players" | grep -m 1 -i playing | awk '{print $1}'`
	
	if [ -z "$player" ]; then 
		if [ -e "$path_last_player" ] && [ -n "`cat "$path_last_player"`" ]; then
			player=`cat "$path_last_player"`
		elif [ -z "$player" ]; then
			player=`echo "$all_players" | sed -n "1p" | awk '{print $1}'`
		fi
	fi

	printf "$player" > "$path_last_player"

}

# nanoseconds to duration string
# @param {int} $1 Nanosecond duration
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

# Shorten a string to a given max length.
# @param {string} $1 The string to be shortened.
# @param {int} $2 The max length
shorten_string () {
	local result="$1"

	if (( ${#result} > $2 )); then
		local length="$[ $2 - 3 ]"
		result="${result:0:$length}..."
	fi

	echo $result
}

update_metadata () {

	local t=`playerctl -p "$player" metadata mpris:length 2>/dev/null`
	[ -n "$t" ] && t=`duration "$t"`

	metadata=$(printf "`playerctl -p "$player" metadata --format "__{{ uc(status) }}__\n{{ playerName }}\n{{ artist }}\n{{ album }}\n{{ title }}\n{{ xesam:trackNumber }}\n{{ duration(position) }}\n__DURATION__\n" 2>/dev/null`")
	metadata="${metadata/__PLAYING__/$icon_playing}"
	metadata="${metadata/__PAUSED__/$icon_paused}"
	metadata="${metadata/__DURATION__/$t}"

}

# Retrieve metadata.
# @param {int} $1 line number
data () {
	echo -n "$metadata" | sed -n "$1 p"
}

# Print formatted output
# @param {string} $1 playerctl event
print_format () {

	# if player in event is not same as var: update player
	(! echo "$1" | awk '{print $1}' | grep -qP "^$player$") && update_player

	if [ -z "$player" ]; then 
		echo ""
		return
	fi

	update_metadata
	local title=`shorten_string "$(data 5)" $title_max_length`
	local result="${templates[$template_index]}"

	result="${result/__STATUS__/`data 1`}"
	result="${result/__PLAYER__/`data 2`}"
	result="${result/__ARTIST__/`data 3`}"
	result="${result/__ALBUM__/`data 4`}"
	result="${result/__TITLE__/$title}"
	result="${result/__TRACK_NUMBER__/`data 6`}"
	result="${result/__POSITION__/`data 7`}"
	result="${result/__DURATION__/`data 8`}"

	echo "$result"

}

# Subscribe to changes in all players. Event frequency is controlled by interval-rate.
# Upon receiving SIGUSR1, the program will cycle through the list of format templates.
# @flag [-r, --interval-rate RATE] {string} - Controls event frequency.
# @flag [-i, --template-index INDEX] {int} - Controls what template is initially used to format the output string.
player_follow () {

	update_metadata
	local rate=`echo "${@}" | grep -Po "((?:\s|^)(?:--interval-rate|-r)\s*\S*)" | awk '{print $2}'`
	local index=`echo "${@}" | grep -Po "((?:\s|^)(?:--template-index|-i)\s*\S*)" | awk '{print $2}'`
	[ -n "$rate" ] && interval_rate=$rate
	[ -n "$index" ] && template_index=$index

	# the interval format is only used to control how often iformation is polled
	local format=""
	case "$interval_rate" in
		high)
			format="{{ playerName }} {{ artist }} {{ title }} {{ status }} {{ position }}"
			;;
		medium)
			format="{{ playerName }} {{ artist }} {{ title }} {{ status }}"
			;;
		low)
			format="{{ playerName }} {{ artist }} {{ title }}"
			;;
	esac

	playerctl -a metadata --format "$format" --follow 2>/dev/null | while read -r event ; do

		trap 'cycle_templates; print_format "$event"' USR1
		print_format "$event"

	done

}

case "$1" in

	# Print all players, ignored players excluded.
	--list)
		list_players
		;;

	# Print the name of the active player
	--active)
		update_player
		echo $player
		;;

	# Automatically select the active player and execute a playerctl command
	--use-active)
		update_player
		if [ -z "$player" ]; then
			echo "No players found." 1>&2
		else
			playerctl -p "$player" "${@:2}"
		fi
		;;

	# Subscribe to changes on all players and print a formatted string whenever something changes
	--follow)
		update_player
		player_follow ${@:2}
		;;

esac


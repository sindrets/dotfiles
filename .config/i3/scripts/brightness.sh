#!/usr/bin/bash
# Usage: brightness.sh [--inc|--dec|--get]   (or set $BACKLIGHT_DEV to force a device)

notify() {
	local icon="${2:-notification-display-brightness-high}"
	printf '%s\n' "$1" >&2
	# notify-replace prints the notification id on stdout; keep stdout for our own output
	notify-replace -a System -t 1000 -i "$icon" "$1" > /dev/null
}

die() {
	notify "$1" notification-display-brightness-missing
	exit 1
}

# --- backlight device detection ---------------------------------------------
# Lower rank == preferred.  Real panel drivers beat the vendor-agnostic
# acpi_video* fallback (which is often a duplicate of a native device).
device_rank() {
	case "$1" in
		intel_backlight)       echo 10 ;;
		amdgpu_bl*)            echo 20 ;;
		radeon_bl*)            echo 30 ;;
		nouveau_bl*|nvidia_*)  echo 40 ;;
		acpi_video*)           echo 90 ;;
		*)                     echo 60 ;;
	esac
}

device_writable() {
	[[ -w "/sys/class/backlight/$1/brightness" ]]
}

detect_backlight() {
	local dir dev rank best_dev="" best_score=99999 score
	if [[ -n "$BACKLIGHT_DEV" ]]; then
		echo "$BACKLIGHT_DEV"
		return 0
	fi

	shopt -s nullglob
	for dir in /sys/class/backlight/*; do
		dev="${dir##*/}"
		rank=$(device_rank "$dev")
		# prefer a device we can actually write to within the same rank
		score=$(( rank * 2 ))
		device_writable "$dev" || score=$(( score + 1 ))
		if (( score < best_score )); then
			best_score=$score
			best_dev=$dev
		fi
	done
	shopt -u nullglob

	[[ -n "$best_dev" ]] && echo "$best_dev"
}

# --- writing ------------------------------------------------------------------
# 1. direct sysfs write (works when udev granted us group write)
# 2. logind: allowed for the *active* session, no root and no group needed
# 3. brightnessctl, as a last resort
backlight_write() {
	local value=$1

	if device_writable "$device"; then
		printf '%s\n' "$value" > "$brightness_file" 2>/dev/null && return 0
	fi

	if [[ -n "$XDG_SESSION_ID" ]] && command -v busctl > /dev/null; then
		busctl call org.freedesktop.login1 \
			"/org/freedesktop/login1/session/$XDG_SESSION_ID" \
			org.freedesktop.login1.Session SetBrightness \
			ssu backlight "$device" "$value" 2>/dev/null && return 0
	fi

	if command -v brightnessctl > /dev/null; then
		brightnessctl -q -d "$device" set "$value" 2>/dev/null && return 0
	fi

	return 1
}

if [[ -n "$BACKLIGHT_DEV" ]]; then
	[[ -e "/sys/class/backlight/$BACKLIGHT_DEV" ]] ||
		die "Backlight '$BACKLIGHT_DEV' not found!"
fi

device=$(detect_backlight)
[[ -n "$device" ]] || die "Couldn't find backlight!"

backlight="/sys/class/backlight/$device"
brightness_file="$backlight/brightness"

max=$(<"$backlight/max_brightness")
max=${max:-0}
(( max > 0 )) || die "Backlight '$device' reports max_brightness 0!"

# never go fully dark: keep at least 1% of the range available
min=$(( (max + 99) / 100 ))
(( min < 1 )) && min=1

nSteps=20
pStep=$(( 100 / nSteps ))
step=$(( max / nSteps ))
(( step < 1 )) && step=1

currentPercent() {
	local current
	current=$(<"$brightness_file")
	echo $(( (current * 100 + max / 2) / max ))
}

modValue() {
	local delta=$1 cur target pct
	cur=$(<"$brightness_file")
	target=$(( cur + delta ))
	(( target > max )) && target=$max

	# snap to the nearest step (in percent) so the readout stays on round numbers
	pct=$(( (target * 100 + max / 2) / max ))
	pct=$(( (pct + pStep / 2) / pStep * pStep ))
	(( pct > 100 )) && pct=100

	result=$(( pct * max / 100 ))
	(( result > max )) && result=$max
	(( result < min )) && result=$min
}

case $1 in
	--inc)
		modValue $step
		backlight_write "$result" || die "Couldn't set brightness on $device!"
		notify "Brightness: $(currentPercent)%" notification-display-brightness-high
		echo "$(currentPercent)"
		;;
	--dec)
		modValue -$step
		backlight_write "$result" || die "Couldn't set brightness on $device!"
		notify "Brightness: $(currentPercent)%" notification-display-brightness-low
		echo "$(currentPercent)"
		;;
	--get)
		echo "$(currentPercent)"
		;;
	*)
		echo "Usage: ${0##*/} [--inc|--dec|--get]" >&2
		exit 2
		;;
esac

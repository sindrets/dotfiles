#!/usr/bin/env sh

pkill polybar || true

sleep 1

randr_out="$(xrandr --current)"

# `DP-4 connected primary 2560x1440+0+0 (normal left inverted right x axis y axis) 597mm x 336mm`
monitor_primary_line="$(echo "$randr_out" | grep primary)"

if [ -z "$monitor_primary_line" ]; then
    monitor_primary_line="$(echo "$randr_out" | grep -P '\bconnected (primary )?\d+x\d+')"
fi

# `DP-4`
export monitor_primary="$(echo "$monitor_primary_line" | cut -d " " -f 1)"

# extract: 2560x1440+0+0
#                   ^^^^
monitor_primary_pos="$( \
    echo "$monitor_primary_line" \
    | awk '{ match($0, /.*? ([0-9]+x[0-9]+)([+-][0-9]+[+-][0-9]+)/, a); print a[2] }' \
)"

# `DP-2 connected 1920x1080+2560+0 (normal left inverted right x axis y axis) 531mm x 299mm`
monitor_secondary_line="$(echo "$randr_out" | grep -P '\bconnected \d+x\d+')"
# `DP-2`
export monitor_secondary="$(echo $monitor_secondary_line | cut -d " " -f 1)"

# extract: 1920x1080+2560+0
#                   ^^^^^^^
monitor_secondary_pos="$( \
    echo "$monitor_secondary_line" \
    | awk '{ match($0, /.*? ([0-9]+x[0-9]+)([+-][0-9]+[+-][0-9]+)/, a); print a[2] }' \
)"

# Disable second monitor bar if:
#   - The same monitor has been matched for primary and secondary.
#   - The screen layout of the two monitors are overlapping.
#   - I don't remember why this third condition is here, but I don't wanna remove it...
if \
    [ "$monitor_primary" = "$monitor_secondary" ] \
    || [ "$monitor_primary_pos" = "$monitor_secondary_pos" ] \
    || [ $(wc -w <<< "$monitor_secondary") -gt 1 ]; \
then
    unset monitor_secondary
fi

export ETH="`ip route | gawk '{ match($0, /^default .*? dev (en\w+)/, a); print a[1] }' | head -n1`"
export WLAN="`ip route | gawk '{ match($0, /^default .*? dev (wl\w+)/, a); print a[1] }' | head -n1`"

[ ! -z "$monitor_primary" ] \
    && echo "primary monitor: $monitor_primary, pos: $monitor_primary_pos"
[ ! -z "$monitor_secondary" ] \
    && echo "secondary monitor: $monitor_secondary, pos: $monitor_secondary_pos"
[ ! -z "$ETH" ] \
    && echo "ETH: $ETH"
[ ! -z "$WLAN" ] \
    && echo "WLAN: $WLAN"

custom_path="$HOME/.config/polybar/custom.ini"
[ ! -e "$custom_path" ] && touch "$custom_path"

pre_launch_path="$HOME/.config/polybar/pre-launch.sh"
[ -e "$pre_launch_path" ] && source "$pre_launch_path"

polybar -r main >> $HOME/.config/polybar/polybar.log 2>&1 &

[ ! -z "$monitor_secondary" ] && polybar -r secondary > /dev/null 2>&1 &

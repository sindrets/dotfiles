#!/usr/bin/env sh

pkill polybar

sleep 1;

randr_out="$(xrandr --current)"

export monitor_primary="$(echo "$randr_out" | grep primary | cut -d " " -f 1)"
if [ -z "$monitor_primary" ]; then
    export monitor_primary="$(echo "$randr_out" | grep -P '\bconnected (primary )?\d+x\d+' | cut -d " " -f 1)"
fi
export monitor_secondary="$(echo "$randr_out" | grep -P '\bconnected (?<!primary )\d+x\d+' | cut -d " " -f 1)"
if [ $(wc -w <<< "$monitor_secondary") -gt 1 ] \
    || [ "$monitor_secondary" = "$monitor_primary" ]; then
    unset monitor_secondary
fi

echo "primary monitor: $monitor_primary"
echo "secondary monitor: $monitor_secondary"

export ETH="`ip route | grep -P '^default( .*){3} en' | awk '{print $5}' | head -n1`"
export WLAN="`ip route | grep -P '^default( .*){3} wl' | awk '{print $5}' | head -n1`"

custom_path="$HOME/.config/polybar/custom.ini"
[ ! -e "$custom_path" ] && touch "$custom_path"

pre_launch_path="$HOME/.config/polybar/pre-launch.sh"
[ -e "$pre_launch_path" ] && source "$pre_launch_path"

polybar -r main >> $HOME/.config/polybar/polybar.log 2>&1 &

[ ! -z "$monitor_secondary" ] && polybar -r secondary > /dev/null 2>&1 &

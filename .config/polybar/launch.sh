#!/usr/bin/env sh

pkill polybar

sleep 1;

export monitor_primary="`xrandr | grep primary | cut -d " " -f 1`"
if [ -z "$monitor_primary" ]; then
    export monitor_primary="`xrandr | grep connected | cut -d " " -f 1`"
fi
export ETH="`ip route | grep -P '^default( .*){3} en' | awk '{print $5}' | head -n1`"
export WLAN="`ip route | grep -P '^default( .*){3} wl' | awk '{print $5}' | head -n1`"

custom_path="$HOME/.config/polybar/custom.ini"
[ ! -e "$custom_path" ] && touch "$custom_path"

pre_launch_path="$HOME/.config/polybar/pre-launch.sh"
[ -e "$pre_launch_path" ] && source "$pre_launch_path"

polybar -r main >> $HOME/.config/polybar/polybar.log 2>&1 &

#!/bin/env sh

pkill polybar

sleep 1;

export monitor_primary="`xrandr | grep primary | cut -d " " -f 1`"
export ETH="`ip route | grep -P '^default( .*){3} en' | awk '{print $5}' | head -n1`"

custom_path="$HOME/.config/polybar/custom.ini"
[ ! -e "$custom_path" ] && touch "$custom_path"

polybar -r main >> $HOME/.config/polybar/polybar.log 2>&1 &

#!/bin/env sh

killall polybar

sleep 1;

export monitor_primary="`xrandr | grep primary | cut -d " " -f 1`"

polybar -r main >> /home/sindrets/.config/polybar/polybar.log 2>&1 &

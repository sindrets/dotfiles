#!/bin/env sh

pkill polybar

sleep 1;

polybar -r i3wmthemer_bar >> /home/sindrets/.config/polybar/polybar.log 2>&1 &

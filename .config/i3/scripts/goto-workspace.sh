#!/bin/bash

cmd=""

if [ -z $1 ]; then
	cmd=`rofi -dmenu \
		-no-fixed-num-lines \
		-p "go to workspace"`

else cmd=$@

fi

[ -z "$cmd" ] && exit 0

i3-msg "workspace $cmd"


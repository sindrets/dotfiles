#!/bin/bash

lock () {
	/home/sindrets/.config/i3lock/blur-lock.sh
}

case "$1" in 

	lock)
		lock
		;;

	logout)
		i3-msg 'exit'
		;;

	switch_user)
		
		;;

	suspend)
		lock && systemctl suspend
		;;

	hibernate)
		lock && systemctl hibernate
		;;

	reboot)
		systemctl reboot
		;;

	shutdown)
		systemctl poweroff
		;;

esac


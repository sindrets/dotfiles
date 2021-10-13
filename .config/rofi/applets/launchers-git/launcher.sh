#!/bin/sh

## Author : Aditya Shakya (adi1090x)
## Mail : adi1090x@gmail.com
## Github : @adi1090x
## Reddit : @adi1090x

# Available Styles
# >> Styles Below Only Works With "rofi-git(AUR)", Current Version: 1.5.4-76-gca067234
#
# blurry	blurry_full		kde_simplemenu		kde_krunner		launchpad
# gnome_do	slingshot		appdrawer			appfolder		column
# row		row_center		screen				row_dock		row_dropdown

style="column_center"
path="`realpath -m $0/../$style`"

rofi -no-lazy-grab -show drun -theme "$path".rasi -modi drun,run,ssh,window

#!/bin/bash
target="$HOME/Pictures/screenshots/`date +'%Y-%m-%d-%H%M%S'`_maim.png"

case "$1" in
	-s)
		maim -s > "$target"
		;;
	-a)
		maim -i `xdotool getactivewindow` | convert - \
			\( +clone -background black -shadow 94x12+0+6 \) \
			+swap -background none -layers merge +repage "$target"
		;;
esac

# copy to clipboard
xclip -selection clipboard -t image/png -i "$target"

dunstify "Screenshot" "Screenshot saved to: '$target'" -i "$target"

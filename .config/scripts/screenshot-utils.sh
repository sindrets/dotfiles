#!/bin/bash
target_dir="$HOME/Pictures/screenshots/"
target="$target_dir/`date +'%Y-%m-%d-%H%M%S'`_maim.png"

mkdir -p "$target_dir"

case "$1" in
    -s)
        maim -s "$target"
        ;;
    -a)
        maim -i $(xdotool getactivewindow) | convert - \
            \( +clone -background black -shadow 94x12+0+6 \) \
            +swap -background none -layers merge +repage "$target"
        ;;
esac

if [ $? -eq 0 ]; then
    # copy to clipboard
    xclip -selection clipboard -t image/png -i "$target"

    dunstify "Screenshot" "Screenshot saved to: '$target'" -i "$target" 
fi


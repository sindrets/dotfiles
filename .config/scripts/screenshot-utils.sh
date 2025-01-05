#!/bin/bash
target_dir="$HOME/Pictures/screenshots/"
target="$target_dir/`date +'%Y-%m-%d-%H%M%S'`_screen.png"

mkdir -p "$target_dir"

case "$1" in
    -s)
        if [ "$XDG_SESSION_TYPE" = "X11" ]; then
            maim -s "$target"
        else
            grim -g "$(slurp)" "$target"
        fi
        ;;
    -a)
        if [ "$XDG_SESSION_TYPE" = "X11" ]; then
            maim -i $(xdotool getactivewindow) | convert - \
                \( +clone -background black -shadow 94x12+0+6 \) \
                +swap -background none -layers merge +repage "$target"
        else
            dunstify "Screenshot" "Not implemented for Wayland"
        fi
        ;;
esac

if [ $? -eq 0 ]; then
    # copy to clipboard
    if [ "$XDG_SESSION_TYPE" = "X11" ]; then
        xclip -selection clipboard -t image/png -i "$target"
    else
        cat "$target" | wl-copy -t image/png
    fi

    dunstify "Screenshot" "Screenshot saved to: '$target'" -i "$target"
fi


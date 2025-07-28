#!/bin/bash
set -eo pipefail

target_dir="$HOME/Pictures/screenshots/"
target="$target_dir/`date +'%Y-%m-%d-%H%M%S'`_screen.png"

mkdir -p "$target_dir"

case "$1" in
    -s)
        if [ "$XDG_SESSION_TYPE" = "x11" ]; then
            maim -s "$target"
        else
            grim -g "$(slurp)" "$target"
        fi
        ;;
    -a)
        if [ "$XDG_SESSION_TYPE" = "x11" ]; then
            maim -i $(xdotool getactivewindow) \
                | convert - \
                    \( +clone -background black -shadow 94x12+0+6 \) \
                    +swap -background none -layers merge +repage "$target"
        else
            if [ "$XDG_CURRENT_DESKTOP" == "sway" ]; then
                swaymsg -t get_tree \
                    | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' \
                    | grim -g - - \
                    | convert - \
                        \( +clone -background black -shadow 94x12+0+6 \) \
                        +swap -background none -layers merge +repage "$target"
            elif [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
                active_window="$(hyprctl -j activewindow)"

                if [ ${#active_window} -le 2 ]; then
                    # No window selected `{}`
                    exit 0
                fi

                jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' <<<"$active_window" \
                    | grim -g - - \
                    | convert - \
                        \( +clone -background black -shadow 94x12+0+6 \) \
                        +swap -background none -layers merge +repage "$target"
            else
                dunstify "Screenshot" "Not implemented for the current environment"
                $?=1
            fi
        fi
        ;;
esac

if [ $? -eq 0 ]; then
    # copy to clipboard
    if [ "$XDG_SESSION_TYPE" = "x11" ]; then
        xclip -selection clipboard -t image/png -i "$target"
    else
        cat "$target" | wl-copy -t image/png
    fi

    dunstify "Screenshot" "Screenshot saved to: '$target'" -i "$target"
fi


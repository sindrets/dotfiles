#!/usr/bin/env bash

lighticon="/home/sindrets/.config/i3lock/img/lock-icon-light-200.png"
darkicon="/home/sindrets/.config/i3lock/img/lock-icon-dark-200.png"
tmpbg='/tmp/i3lock-bg.png'

# take a screenshot
scrot "$tmpbg"

# set a threshold value to determine if we should use the light icon or dark
# icon
VALUE="60" #brightness value to compare to

# determine the color of the screenshot
# thanks to [i3lock-fancy](https://github.com/meskarune/i3lock-fancy) for the
# idea of getting the background color to change the icons
COLOR=$(convert "$tmpbg" -gravity center -crop 100x100+0+0 +repage -colorspace hsb \
    -resize 1x1 txt:- | awk -F '[%$]' 'NR==2{gsub(",",""); printf "%.0f\n", $(NF-1)}');

# change the color ring colors to leave the middle of the feedback ring
# transparent and the outside to use either dark or light colors based on the 
# screenshot
if [ "$COLOR" -gt "$VALUE" ]; then #light background, use dark icon
    icon="$darkicon"
    PARAM=(--greetercolor=333333ff --verifcolor=333333ff --layoutcolor=333333ff --insidecolor=00000000 --ringcolor=0000003e \
        --linecolor=00000000 --keyhlcolor=ffffff80 --ringvercolor=ffffff00 \
        --separatorcolor=22222260 --insidevercolor=ffffff1c \
        --ringwrongcolor=ffffff55 --insidewrongcolor=ffffff1c)
else # dark background so use the light icon
    icon="$lighticon"
    PARAM=(--greetercolor=edededff --verifcolor=edededff --layoutcolor=edededff --insidecolor=ffffff00 --ringcolor=ffffff3e \
        --linecolor=ffffff00 --keyhlcolor=00000080 --ringvercolor=00000000 \
        --separatorcolor=22222260 --insidevercolor=0000001c \
        --ringwrongcolor=00000055 --insidewrongcolor=0000001c)
fi

# blur the screenshot by resizing and scaling back up
#convert "$tmpbg" -filter Gaussian -thumbnail 20% -sample 500% "$tmpbg"
convert "$tmpbg" -scale 10% -blur 0x5 -resize 1000% "$tmpbg"

# overlay the icon onto the screenshot
convert "$tmpbg" "$icon" -gravity center -composite "$tmpbg"

# lock the screen with the color parameters
i3lock "${PARAM[@]}" --radius 140 --greetertext="Enter password to unlock" -i "$tmpbg"

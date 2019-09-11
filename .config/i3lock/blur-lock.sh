#!/usr/bin/env bash

lighticon="/home/sindrets/.config/i3lock/img/lock-icon-light-200.png"
darkicon="/home/sindrets/.config/i3lock/img/lock-icon-dark-200.png"
tmpbg='/tmp/i3lock-bg.png'
darken_amount=20

# take a screenshot
scrot -o "$tmpbg" --quality 100

# set a threshold value to determine if we should use the light icon or dark
# icon
VALUE="60" #brightness value to compare to

# parse dimensions + position of primary display, to center icon on multi-monitor setups
resPos="$(xrandr | grep primary | awk '{print $4}')"

width="$(echo $resPos | perl -lne 'print $& if /[0-9]*(?=x)/')"
height="$(echo $resPos | perl -lne 'print $& if /(?<=x)[0-9]*/')"

offsetX="$(echo $resPos | perl -lne 'print $& if /(?<=\+)[0-9]*/')"
offsetY="$(echo $resPos | perl -lne 'print $& if /(?<=\+)[0-9]*$/')"

# determine the average color of the center of the primary monitor.
cropSize=300
COLOR=$(convert "$tmpbg" -crop "$cropSize"x"$cropSize"+$(expr $offsetX + $width / 2 - $cropSize / 2)+$(expr $offsetY + $height / 2 - $cropSize / 2) \
	+repage -colorspace hsb -brightness-contrast -"$darken_amount"x0 -resize 1x1 txt:- | awk -F '[%$]' 'NR==2{gsub(",",""); printf "%.0f\n", $(NF-1)}');

# change the color ring colors to leave the middle of the feedback ring
# transparent and the outside to use either dark or light colors based on the 
# screenshot
if [ "$COLOR" -gt "$VALUE" ]; then #light background, use dark icon
    icon="$darkicon"
    PARAM=( 
		--greetercolor=333333ff --verifcolor=333333ff \
		--layoutcolor=333333ff --insidecolor=00000000 \
		--ringcolor=0000003e --linecolor=00000000 \
		--keyhlcolor=ffffff80 --ringvercolor=ffffff00 \
		--separatorcolor=22222260 --insidevercolor=ffffff1c \
		--ringwrongcolor=ffffff55 --insidewrongcolor=ffffff1c 
	)

else # dark background so use the light icon
    icon="$lighticon"
    PARAM=( 
		--greetercolor=edededff --verifcolor=edededff \
		--layoutcolor=edededff --insidecolor=ffffff00 \
		--ringcolor=ffffff3e --linecolor=ffffff00 \
		--keyhlcolor=00000080 --ringvercolor=00000000 \
		--separatorcolor=22222260 --insidevercolor=0000001c \
		--ringwrongcolor=00000055 --insidewrongcolor=0000001c 
	)
fi

iconHWidth="`expr $(identify -format '%w' "$icon") / 2`"
iconHHeight="`expr $(identify -format '%h' "$icon") / 2`"

# blur the screenshot by resizing and scaling back up
#convert "$tmpbg" -filter Gaussian -thumbnail 20% -sample 500% "$tmpbg"
convert "$tmpbg" -scale 10% -blur 0x6 -resize 1000% -brightness-contrast -"$darken_amount"x-"$darken_amount" \
	"$icon" -geometry +"`expr $width / 2 + $offsetX - $iconHWidth`"+"`expr $height / 2 + $offsetY - $iconHHeight`" -composite "$tmpbg"

# lock the screen with the color parameters
i3lock "${PARAM[@]}" --radius 140 --greetertext="Enter password to unlock" -i "$tmpbg"

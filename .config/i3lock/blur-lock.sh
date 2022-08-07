#!/usr/bin/env zsh

lighticon="/home/sindrets/.config/i3lock/img/lock-icon-light-200.png"
darkicon="/home/sindrets/.config/i3lock/img/lock-icon-dark-200.png"
tmpbg='/tmp/i3lock-bg.jpg'
darken_amount=20
ind_radius=140

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
COLOR=$( \
  convert "$tmpbg" -crop \
  "$cropSize"x"$cropSize"+$(expr $offsetX + $width / 2 - $cropSize / 2)+$(expr $offsetY + $height / 2 - $cropSize / 2) \
  +repage -colorspace hsb -brightness-contrast -"$darken_amount"x0 -resize 1x1 txt:- \
  | awk -F '[%$]' 'NR==2{gsub(",",""); printf "%.0f\n", $(NF-1)}' \
);

# change the color ring colors to leave the middle of the feedback ring
# transparent and the outside to use either dark or light colors based on the 
# screenshot
if [ "$COLOR" -gt "$VALUE" ]; then #light background, use dark icon
  icon="$darkicon"
  PARAM=(
    --greeter-color=333333ff \
    --time-color=333333ff \
    --date-color=333333ff \
    --verif-color=333333ff \
    --layout-color=333333ff \
    --inside-color=00000000 \
    --ring-color=0000003e \
    --line-color=00000000 \
    --keyhl-color=ffffff80 \
    --ringver-color=ffffff00 \
    --separator-color=22222260 \
    --insidever-color=ffffff1c \
    --ringwrong-color=ffffff55 \
    --insidewrong-color=ffffff1c \
    --wrong-color=333333ff
  )

else # dark background so use the light icon
  icon="$lighticon"
  PARAM=( 
    --greeter-color=edededff \
    --time-color=edededff \
    --date-color=edededff \
    --verif-color=edededff \
    --layout-color=edededff \
    --inside-color=ffffff00 \
    --ring-color=ffffff3e \
    --line-color=ffffff00 \
    --keyhl-color=00000080 \
    --ringver-color=00000000 \
    --separator-color=22222260 \
    --insidever-color=0000001c \
    --ringwrong-color=00000055 \
    --insidewrong-color=0000001c \
    --wrong-color=edededff
  )
fi

iconHWidth="$[$(identify -format '%w' "$icon") / 2]"
iconHHeight="$[$(identify -format '%h' "$icon") / 2]"

# blur the screenshot by resizing and scaling back up (faster than gaussian blur)
#convert "$tmpbg" -filter Gaussian -thumbnail 20% -sample 500% "$tmpbg"
convert "$tmpbg" -scale 10% -blur 0x6 -resize 1000% -brightness-contrast -"$darken_amount"x-"$darken_amount" \
    "$icon" -geometry +"$[$width / 2 + $offsetX - $iconHWidth]"+"$[$height / 2 + $offsetY - $iconHHeight - $ind_radius - $iconHHeight - 30]" -composite "$tmpbg"

time_size=64
date_size=16

# lock the screen with the color parameters
i3lock "${PARAM[@]}" \
  --indicator \
  --radius $ind_radius \
  --clock \
  --time-str="%H:%M" \
  --time-size=$time_size \
  --date-size=$date_size \
  --time-pos="x + w / 2 : y + h / 2 + $date_size / 2" \
  --greeter-text="Enter password to unlock" \
  --greeter-pos="x + w / 2 : y + h / 2 + r + 60" \
  --screen=0 \
  -i "$tmpbg"

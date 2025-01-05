#!/usr/bin/env bash

lighticon="/home/sindrets/.config/i3lock/img/lock-icon-light-200.png"
darkicon="/home/sindrets/.config/i3lock/img/lock-icon-dark-200.png"
tmpbg='/tmp/i3lock-bg.jpg'
darken_amount=5
ind_radius=150

# take a screenshot
if [ "$XDG_SESSION_TYPE" = "X11" ]; then
  scrot -o "$tmpbg" --quality 100
else
  grim -t jpeg -q 100 "$tmpbg"
fi

# set a threshold value to determine if we should use the light icon or dark
# icon
VALUE="60" #brightness value to compare to

# parse dimensions + position of primary display, to center icon on multi-monitor setups
randrData="$(xrandr --current)"
resPos="$(echo "$randrData" | grep primary | awk '{print $4}')"

if [[ -z "$resPos" ]]; then
  resPos="$(echo "$randrData" | grep ' connected ' | awk '{print $3}')"
fi

scaling_factor=1.0
width="$(echo $resPos | perl -lne 'print $& if /[0-9]*(?=x)/')"
height="$(echo $resPos | perl -lne 'print $& if /(?<=x)[0-9]*/')"

offsetX="$(echo $resPos | perl -lne 'print $& if /(?<=\+)[0-9]*/')"
offsetY="$(echo $resPos | perl -lne 'print $& if /(?<=\+)[0-9]*$/')"

if [ ! "$XDG_SESSION_TYPE" == "X11" ]; then
  scaling_factor="$(swaymsg --raw -t get_outputs | jq -r '.[0] | "\(.scale)"')"

  width="$(perl -e "print(int($width * $scaling_factor))")"
  height="$(perl -e "print(int($height * $scaling_factor))")"
  offsetX="$(perl -e "print(int($offsetX * $scaling_factor))")"
  offsetY="$(perl -e "print(int($offsetY * $scaling_factor))")"
fi

# determine the average color of the center of the primary monitor.
cropSize=300
COLOR=$( \
  magick "$tmpbg" -crop \
    "$cropSize"x"$cropSize"+$(expr $offsetX + $width / 2 - $cropSize / 2)+$(expr $offsetY + $height / 2 - $cropSize / 2) \
    +repage -colorspace hsb -brightness-contrast -"$darken_amount"x0 -resize 1x1 txt:- \
    | awk -F '[%$]' 'NR==2{gsub(",",""); printf "%.0f\n", $(NF-1)}' \
);

# change the color ring colors to leave the middle of the feedback ring
# transparent and the outside to use either dark or light colors based on the 
# screenshot
if [ "$COLOR" -gt "$VALUE" ]; then #light background, use dark icon
  icon="$darkicon"
  if [ "$XDG_SESSION_TYPE" = "X11" ]; then
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
  else
    PARAM=(
      --text-color 333333ff \
      --text-ver-color 333333ff \
      --text-wrong-color 333333ff \
      --text-clear-color 333333ff \
      --layout-text-color edededff \
      --key-hl-color ffffff80 \
      --separator-color 22222260 \
      --line-color 00000080 \
      --inside-color 00000000 \
      --inside-ver-color ffffff1c \
      --inside-wrong-color ffffff1c \
      --ring-color 0000003e \
      --ring-ver-color 0000003e \
      --ring-wrong-color 0000003e
    )
  fi

else # dark background so use the light icon
  icon="$lighticon"
  if [ "$XDG_SESSION_TYPE" = "X11" ]; then
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
  else
    PARAM=(
      --text-color edededff \
      --text-ver-color edededff \
      --text-wrong-color edededff \
      --text-clear-color edededff \
      --layout-text-color edededff \
      --key-hl-color 00000080 \
      --separator-color 22222260 \
      --line-color ffffff00 \
      --inside-color ffffff00 \
      --inside-ver-color 0000001c \
      --inside-wrong-color 0000001c \
      --ring-color ffffff3e \
      --ring-ver-color ffffff3e \
      --ring-wrong-color ffffff3e
    )
  fi
fi

iconHWidth="$[$(identify -format '%w' "$icon") / 2]"
iconHHeight="$[$(identify -format '%h' "$icon") / 2]"

# blur the screenshot by resizing and scaling back up (faster than gaussian blur)
#convert "$tmpbg" -filter Gaussian -thumbnail 20% -sample 500% "$tmpbg"
magick "$tmpbg" \
  -scale 16.66% \
  -blur 0x6 \
  -resize 600% \
  -brightness-contrast \
  -"$darken_amount"x-"$darken_amount" \
    "$icon" -geometry +"$[$width / 2 + $offsetX - $iconHWidth]"+"$(
      perl -e "print int($height / 2 + $offsetY - \
        $ind_radius * $scaling_factor - \
        $iconHHeight * 2 - \
        30 * $scaling_factor)"
    )" \
  -composite "$tmpbg"

time_size=64
date_size=16

# lock the screen with the color parameters
if [ "$XDG_SESSION_TYPE" = "X11" ]; then
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
else
  swaylock "${PARAM[@]}" \
    --indicator \
    --indicator-radius $ind_radius \
    --clock \
    --timestr "%H:%M" \
    --font-size "$(perl -e "print 48 * $scaling_factor")" \
    --fade-in 0.3 \
    --grace 2 \
    --grace-no-mouse \
    -i "$tmpbg"
fi

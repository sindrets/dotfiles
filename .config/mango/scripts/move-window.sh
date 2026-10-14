#!/usr/bin/bash
# Move the focused window: tiled -> move_client (reorder in layout),
# floating -> nudge by a fixed number of pixels.
# (Port of hyprland's smart_move script, which did the same thing.)
# Usage: move-window.sh <left|right|up|down>

set -e
dir=${1:?usage: move-window.sh <left|right|up|down>}

STEP=30
floating=$(mmsg get focusing-client | jq -r '.is_floating // false')

case "$floating" in
  true)
    case "$dir" in
      left)  mmsg dispatch movewin,"-$STEP,+0" ;;
      right) mmsg dispatch movewin,"+$STEP,+0" ;;
      up)    mmsg dispatch movewin,"+0,-$STEP" ;;
      down)  mmsg dispatch movewin,"+0,+$STEP" ;;
    esac
    ;;
  *)
    mmsg dispatch move_client,"$dir"
    ;;
esac

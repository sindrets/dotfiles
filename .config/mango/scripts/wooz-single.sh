#!/usr/bin/bash
# Spawn wooz only if it isn't already running, so repeated magnify
# binds don't pile up multiple instances.
set -e

if pgrep -x wooz >/dev/null 2>&1; then
  exit 0
fi

current_output="$(
  mmsg get all-monitors \
    | jq -r 'first(.monitors[] | select(.active == true)).name'
)"
exec wooz --output "$current_output" --invert-scroll --map-close q --zoom-in '25%'

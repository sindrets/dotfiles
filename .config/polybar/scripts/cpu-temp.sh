#!/bin/sh

sensors_output="$(sensors 2> /dev/null)"

intel_core="$( \
  echo "$sensors_output" \
    | gawk '{
      match($0, /^Package id [0-9]+:\s*[+-]([0-9]+)(\.[0-9]+)?/, a);
      if (a[1]) { print a[1] };
    }' \
)"

if [ ! -z "$intel_core" ]; then
  echo "$intel_core°C"
  exit 0
fi

amd_core="$(echo "$sensors_output" | grep Tctl)"

if [ ! -z "$amd_core" ]; then
  echo "$amd_core" \
    | awk '{sub("+", "", $2); print $2}'

  exit 0
fi

echo "??"

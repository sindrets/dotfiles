#!/bin/sh

sensors_output="$(sensors 2> /dev/null)"

intel_core="$(echo "$sensors_output" | grep Core)"

if [ ! -z "$intel_core" ]; then
  echo "$intel_core" \
    | awk '{print substr($3, 2, length($3)-5)}' \
    | tr "\\n" " " \
    | sed 's/ /°C  /g' \
    | sed 's/  $//'

  exit 0
fi

amd_core="$(echo "$sensors_output" | grep Tctl)"

if [ ! -z "$amd_core" ]; then
  echo "$amd_core" \
    | awk '{sub("+", "", $2); print $2}'

  exit 0
fi

echo "??"

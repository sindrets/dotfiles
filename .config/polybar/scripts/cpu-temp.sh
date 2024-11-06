#!/bin/sh

sensors_output="$(sensors 2> /dev/null)"

intel_core_temp="$(
  echo "$sensors_output" \
    | perl -n -e '/^Package id \d+:\s*[+-](\d+(\.\d+)?°[CF])/ && print ($1 =~ s/\+//rg)'
)"

if [ ! -z "$intel_core_temp" ]; then
  echo "$intel_core_temp"
  exit 0
fi

amd_core_temp="$(
  echo "$sensors_output" \
    | perl -n -e '/^Tctl:\s*([+-]\d+(\.\d+)?°[CF])/ && print ($1 =~ s/\+//rg)'
)"

if [ ! -z "$amd_core_temp" ]; then
  echo "$amd_core_temp"
  exit 0
fi

echo "??"

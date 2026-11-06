#!/usr/bin/bash
# Spawn wooz only if it isn't already running, so repeated magnify
# binds don't pile up multiple instances.
set -e

if pgrep -x wooz >/dev/null 2>&1; then
  exit 0
fi

exec wooz --map-close q --no-aa --zoom-in '50%'

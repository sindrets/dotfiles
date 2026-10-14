#!/usr/bin/bash
# Cycle to the next/previous tag that has windows on the focused monitor, wrapping around.
# (hyprland mod+Tab / mod+SHIFT+Tab equivalent; mangowm's *_have_client dispatchers don't wrap)
# Usage: cycle-tags.sh [next|prev]

set -e
dir=${1:-next}

target=$(mmsg get all-tags | jq -r --arg mon "$(mmsg get focusing-client | jq -r .monitor)" --arg dir "$dir" '
  (.all_tags[] | select(.monitor == $mon) | .tags) as $tags
  | [ $tags[] | select(.client_count > 0) ] as $occ
  | ( [ $tags[] | select(.is_active) ] | .[0].index ) as $cur
  | if ($occ | length) <= 1 then empty
    else
      if $dir == "next" then
        ( [ range(0; $occ|length) ] | map(select($occ[.].index > $cur)) | if length > 0 then .[0] else 0 end )
      else
        ( [ range(0; $occ|length) ] | map(select($occ[.].index < $cur)) | if length > 0 then .[-1] else ($occ|length)-1 end )
      end as $p
      | $occ[$p].index
    end
')

[ -n "$target" ] && mmsg dispatch view,"$target"

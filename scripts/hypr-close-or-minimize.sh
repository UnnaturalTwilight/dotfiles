#!/usr/bin/bash
# 
# Based on https://wiki.hypr.land/Configuring/Uncommon-tips--tricks/

if [ "$(hyprctl activewindow -j | jq -r ".initialTitle")" = "Mozilla Thunderbird" ]; then
  if [ "$(hyprctl activewindow -j | jq -r ".workspace.name")" = "special:thunderbird" ]; then
    hyprctl dispatch togglespecialworkspace thunderbird
  else
    hyprctl dispatch movetoworkspacesilent special:thunderbird,active
  fi
else
    hyprctl dispatch killactive ""
fi


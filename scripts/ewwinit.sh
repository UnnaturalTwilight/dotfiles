#! /bin/sh 

if [ "$1" = "niri" ]; then
    eww open bg-clock
elif [ "$1" = "hyprland" ]; then
    eww open bar
else
    echo "$1"
fi
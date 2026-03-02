#! /bin/sh 

if [ "$1" = "niri" ]; then
    # eww --config=$HOME/.config/eww_niri open-many \
        # bg-workspaces:eDP-1 --arg "eDP-1:monitor=eDP-1" \
        # bg-workspaces:DP-4 --arg "DP-4:monitor=DP-4" \
        # bg-symbols \
        # bg-clock
    eww daemon
elif [ "$1" = "hyprland" ]; then
    eww open bar
else
    echo "$1"
fi

rm -f $HOME/.cache/eww_start.lock

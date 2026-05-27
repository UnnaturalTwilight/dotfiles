#!/bin/sh
kitty +kitten panel --layer=top --focus-policy=on-demand --edge=center-sized --lines=40 --columns=140 \
    -o allow_remote_control=yes --app-id=unicode -- \
    sh -c 'kitten unicode-input | wl-copy -n -t "text/plain"; kitten @ close-window --self'

#!/bin/sh

# Simple notification test
notify-send -a test-notif -i info -n bash -c "test" 'Hello!!' \
    'This is a test notification. It should appear on your screen with the title "Hello!!" and the message "This is a test notification."'
sleep 0.2

# Progress bar test
id=$(notify-send "Progress bar" "Value: 0%" -h int:value:0 -c "test" -e -p)
sleep 0.5
for x in {1..10}; do
    notify-send "Progress bar" "Value: ${x}0%" -h int:value:$((x*10)) -c "test" -e -r $id
    sleep 0.2
done

# Action buttons test
selection=$(notify-send -a test-notif -i bash -c "test" -e --action=#{0..5} --action="BUTTON" "Lots of buttons")
sleep 0.2
notify-send -a test-notif -n info -t 3000 -c "test" -e "You clicked button $selection"
sleep 0.2

# Test for the rewrite scripts
notify-send -a rewrite-test -c "test" "THIS SHOULD NOT BE SEEN" "THIS SHOULD NOT BE SEEN"

#!/bin/sh

qs --config niri-backdrop ipc call notifs clear
sleep 0.1

# Simple notification test
notify-send -a test-notif -i info -n bash -c "test" 'Hello!!' \
    'This is a test notification. It should appear on your screen with the title "Hello!!" and the message "This is a test notification."'
sleep 0.2

# Test for the rewrite scripts
notify-send -a rewrite-test -c "test" -h "int:action-icons:1" "THIS SHOULD NOT BE SEEN" "THIS SHOULD NOT BE SEEN"
sleep 0.2

# Thunderbird has the most rewrites and is difficult to test so fake a notification from it
notify-send \
    -a "Thunderbird" \
    -c "test" \
    -h "string:desktop-entry:org.mozilla.Thunderbird" \
    -A "default=Activate" \
    -A "Other Action" \
    "Thunderbird" \
    "Example Test Notification" &
sleep 0.2

# Progress bar test
id=$(notify-send "Progress bar" "Value: 0%" -h int:value:0 -c "test" -e -p -u critical)
sleep 0.5
for x in {1..9}; do
    id=$(notify-send "Progress bar" "Value: ${x}0%" -h int:value:$((x*10)) -c "test" -e -r $id -p -u critical)
    sleep 0.2
done
notify-send "Progress bar" "Value: 100%" -h int:value:100 -c "test" -e -r $id

# Action buttons test
selection=$(notify-send -a test-notif -i bash -c "test" -e --action=#{0..3} --action="error=BUTTON" -h "int:action-icons:1" "Lots of buttons")
echo "You clicked button $selection"
sleep 0.2
notify-send -a test-notif -n info -t 3000 -c "test" -e "You clicked button $selection"
sleep 0.2
notify-send \
    -a "test-notif" \
    -c "test" -e \
    -h "string:desktop-entry:quickshell" \
    -A "inline-reply=BOOP" \
    -A default=Action \
    "Test Notification with inline reply"
sleep 0.2

# Test fallbacks
notify-send -a "" -c "test" ""

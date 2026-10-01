#!/bin/sh

qs --config niri-backdrop ipc call notifs clear
sleep 0.1

# Simple notification test
notify-send \
    -a test-notif \
    -i info \
    -h "string:desktop-entry:org.quickshell" \
    -c "test" '<b>Hello!!</b>' \
    'This is a test notification. It should appear on your screen with the title <b>"Hello!!"</b> and the message "This is a test notification."'
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

function progress_bar() {
    local value=$1
    local id=$2
    local icon="file://$XDG_CONFIG_HOME/assets/Icons/battery/${3}.svg"

    notify-send "Progress bar" "Value: ${value}%" -a "progress-test" \
        -h int:value:${value} -c "test" -e -p -u critical -r $id -i $icon
}

# Progress bar test
id=$(progress_bar 0 0 outline)
sleep 0.5
for x in {1..9}; do
    id=$(progress_bar $((x*10)) $id $((x*10)))
    sleep 0.2
done
notify-send "Progress bar" "Value: 100%" -a "progress-test" \
    -h int:value:100 -c "test" -e -r $id \
    -i "file://$XDG_CONFIG_HOME/assets/Icons/battery/full.svg"
sleep 0.2

# Action buttons test
selection=$(notify-send -a test-notif -i bash -c "test" -e --action=#{0..3} --action="error=BUTTON" -h "int:action-icons:1" "Lots of buttons")
sleep 0.2

if [ -n "$selection" ]; then
    echo "You clicked button $selection"
    notify-send -a test-notif -n info -t 3000 -c "test" -e "You clicked button $selection"
    sleep 0.2
fi

notify-send \
    -a "test-notif" \
    -c "test" -e \
    -n "file://$XDG_CONFIG_HOME/profilepic.png" \
    -h "string:desktop-entry:org.quickshell" \
    -A "inline-reply=BOOP" \
    "Test Notification with inline reply" &
sleep 0.5

# Test fallbacks
notify-send -a "" -c "test" ""
sleep 0.5

action=$(notify-send \
    -a "test-notif" \
    -c "test" -e -t 90000 \
    -h "string:desktop-entry:org.quickshell" \
    -A "rerun=Rerun Test" \
    -A "clear=Clear All" \
    -A "default=Done" \
    "Test Completed")

if [ -n "$action" ]; then
    echo "You clicked button $action"
    case $action in
        rerun)
            echo "Rerunning test"
            sleep 0.2
            $0
            ;;
        clear)
            echo "Clearing all notifications"
            qs --config niri-backdrop ipc call notifs clear
            ;;
        default)
            echo "Done"
            ;;
    esac
fi

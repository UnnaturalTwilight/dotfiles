// Idle.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Singleton {
    id: root
    reloadableId: "Idle"

    property bool idle: false
    property bool enabled: false
    property bool respectInhibitors: true

    IdleMonitor {
        id: screenDimmer

        property bool triggered: false
        respectInhibitors: root.respectInhibitors
        enabled: root.enabled

        timeout: 240 // 4min

        onIsIdleChanged: {
            root.idle = isIdle;

            if (isIdle && !triggered) {
                Quickshell.execDetached(["brightnessctl", "-s", "set", "10"]);
            } else if (!isIdle && triggered) {
                Quickshell.execDetached(["brightnessctl", "-r"]);
            }

            triggered = isIdle;
        }
    }

    IdleMonitor {
        id: screenLocker

        property bool triggered: false
        respectInhibitors: root.respectInhibitors
        enabled: root.enabled

        timeout: 300 // 5min

        onIsIdleChanged: {
            if (isIdle && !triggered) {
                hyprlock.startDetached();
                triggered = true; 
            }
        }
    }

    IdleMonitor {
        id: keyboardBacklight

        property bool triggered: false
        respectInhibitors: root.respectInhibitors
        enabled: root.enabled

        timeout: 330 // 5.5min

        onIsIdleChanged: {
            if (isIdle && !triggered) {
                Quickshell.execDetached(["brightnessctl", "-sd", "chromeos::kbd_backlight", "set", "0"]);
            } else if (!isIdle && triggered) {
                Quickshell.execDetached(["brightnessctl", "-rd", "chromeos::kbd_backlight"]);
            }

            triggered = isIdle;
        }    
    }

    // replace with Quickshell native lockscreen
    Process {
        id: hyprlock
        running: false
        command: ["hyprlock", "--grace", "3"]
        onExited: {
            screenLocker.triggered = false;
        }
    }
}

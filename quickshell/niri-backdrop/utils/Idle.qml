// Idle.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

import qs.utils
import qs.utils.niri

Singleton {
    id: root
    reloadableId: "Idle"

    property bool idle: false
    property bool enabled: false
    property bool respectInhibitors: true

    property alias screenLocked: screenLocker.triggered

    IdleMonitor {
        id: screenDimmer

        property bool triggered: false
        respectInhibitors: root.respectInhibitors
        enabled: root.enabled

        timeout: 240 // 4min

        onIsIdleChanged: {
            root.idle = isIdle;

            if (isIdle && !triggered) {
                Brightness.dimScreen();
            } else if (!isIdle && triggered) {
                Brightness.restoreBrightness();
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
                // not the cleanest solution but it works
                Quickshell.execDetached(["qs", "--config", "niri-backdrop", "ipc", "call", "lock", "lock"]);
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
                Brightness.keyboardBacklight(false);
            } else if (!isIdle && triggered) {
                Brightness.keyboardBacklight(true);
            }

            triggered = isIdle;
        }
    }

    IdleMonitor {
        id: screenOff

        property bool triggered: false
        respectInhibitors: root.respectInhibitors
        enabled: root.enabled

        timeout: 360 // 6min

        onIsIdleChanged: {
            if (isIdle && !triggered) {
                Niri.sleepDisplay();
            }

            triggered = isIdle;
        }
    }

    IdleMonitor {
        id: suspend

        property bool triggered: false
        respectInhibitors: root.respectInhibitors
        enabled: root.enabled && !Music.playing

        timeout: 600 // 10min

        onIsIdleChanged: {
            if (isIdle && !triggered) {
                Quickshell.execDetached(["systemctl", "hybrid-sleep"]);
            }

            triggered = isIdle;
        }
    }
}

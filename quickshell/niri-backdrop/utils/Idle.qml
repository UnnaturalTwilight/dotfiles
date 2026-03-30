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

    property alias idle: dimTimer.triggered
    property alias locked: lockTimer.triggered
    property bool enabled: false
    property bool respectInhibitors: true

    property bool inhibitLock: false
    // Will never suspend if MPD is playing music regardless of this value
    property bool inhibitSuspend: false

    function setIdle(): void {
        Brightness.dimScreen();
        dimTimer.triggered = true;
    }

    function wake(): void {
        suspendTimer.triggered = false;
        dimTimer.triggered = false;
        Brightness.keyboardBacklight(true);
        Brightness.restoreBrightness();
    }

    function sleep(): void {
        lockTimer.triggered = true;
        Brightness.keyboardBacklight(false);
        Quickshell.execDetached(["qs", "--config", "niri-backdrop", "ipc", "call", "lock", "lock"]);
        Niri.sleepDisplay();
    }

    function suspend(): void {
        suspendTimer.triggered = true;
        if (!lockTimer.triggered) {
            sleep();
        }
        Quickshell.execDetached(["systemctl", "suspend-then-hibernate"]);
    }

    IdleMonitor {
        id: dimTimer

        property bool triggered: false
        respectInhibitors: root.respectInhibitors
        enabled: root.enabled

        timeout: 240 // 4min

        onIsIdleChanged: {
            if (isIdle && !triggered) {
                root.setIdle();
            } else if (!isIdle && triggered) {
                root.wake();
            }
        }
    }

    IdleMonitor {
        id: lockTimer

        property bool triggered: false
        respectInhibitors: root.respectInhibitors
        enabled: root.enabled && !root.inhibitLock

        timeout: 300 // 5min

        onIsIdleChanged: {
            if (isIdle && !triggered) {
                root.sleep();
            }
        }
    }

    IdleMonitor {
        id: suspendTimer

        property bool triggered: false
        respectInhibitors: root.respectInhibitors
        enabled: root.enabled && !Music.playing && !root.inhibitSuspend

        timeout: 600 // 10min

        onIsIdleChanged: {
            if (isIdle && !triggered) {
                root.suspend();
            }
        }
    }
}

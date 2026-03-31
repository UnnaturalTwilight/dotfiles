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

    onIdleChanged: {
        idleIPC.idleChanged(idle);
    }

    function setIdle(): void {
        Brightness.dimScreen();
        dimTimer.triggered = true;
    }

    function wake(): void {
        suspendTimer.triggered = false;
        dimTimer.triggered = false;
        Brightness.keyboard(true);
        Brightness.restoreScreen();
    }

    function sleep(): void {
        lockTimer.triggered = true;
        Brightness.keyboard(false);
        lock();
        Niri.sleepDisplay();
    }

    function suspend(): void {
        suspendTimer.triggered = true;
        if (!lockTimer.triggered) {
            sleep();
        }
        Quickshell.execDetached(["systemctl", "suspend-then-hibernate"]);
    }

    signal lock

    IpcHandler {
        id: idleIPC
        target: "idle"

        function inhibit(inhibited: bool): void {
            root.enabled = !inhibited;
        }
        function respectInhibitors(enabled: bool): void {
            root.respectInhibitors = enabled;
        }
        function inhibitLock(enabled: bool): void {
            root.inhibitLock = enabled;
        }
        function inhibitSuspend(enabled: bool): void {
            root.inhibitSuspend = enabled;
        }

        function inhibited(): bool {
            return !root.enabled;
        }

        function set(action: string): void {
            if (action === "idle") {
                root.setIdle();
            } else if (action === "wake") {
                root.wake();
            } else if (action === "sleep") {
                root.sleep();
            } else if (action === "suspend") {
                root.suspend();
            } else {
                console.warn("Idle IPC: unknown action '" + action + "'");
            }
        }

        signal idleChanged(bool idle)
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

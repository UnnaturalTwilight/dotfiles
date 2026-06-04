// Idle.qml
pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

import qs.services
import qs.services.niri

Singleton {
    id: root
    reloadableId: "Idle"

    readonly property alias idle: dimTimer.triggered
    property alias locked: lockTimer.triggered

    property alias enabled: persist.enabled
    property alias respectInhibitors: persist.respectInhibitors
    property alias inhibitLock: persist.inhibitLock
    // Will never suspend if MPD is playing music regardless of this value
    property alias inhibitSuspend: persist.inhibitSuspend

    onIdleChanged: {
        idleIPC.idleChanged(idle);
    }

    function setIdle(): void {
        Brightness.dimScreen();
        dimTimer.triggered = true;
    }

    function wake(): void {
        dimTimer.triggered = false;
        Brightness.keyboard(true);
        Brightness.restoreScreen();
    }

    function sleep(): void {
        Brightness.keyboard(false);
        lock();
        Niri.sleepDisplay();
        console.log("Idle: sleep");
        if (!Music.playing && !root.inhibitSuspend) {
            // If music is playing or suspend is inhibited just turn off the screen instead of actually sleeping
            Quickshell.execDetached(["systemctl", "sleep"]);
        }
    }

    function suspend(): void {
        console.log("Idle: suspend");
        Quickshell.execDetached(["systemctl", "suspend-then-hibernate"]);
    }

    function hibernate(): void {
        console.log("Idle: hibernate");
        Quickshell.execDetached(["systemctl", "hibernate"]);
    }

    signal lock

    IpcHandler {
        id: idleIPC
        target: "idle"

        function respectInhibitors(enabled: bool): void {
            persist.respectInhibitors = enabled;
        }

        function setInhibitors(level: string, inhibited: bool): void {
            if (level === "idle") {
                persist.enabled = !inhibited;
            } else if (level === "lock") {
                persist.inhibitLock = inhibited;
            } else if (level === "suspend") {
                persist.inhibitSuspend = inhibited;
            } else {
                console.warn("Idle IPC: unknown inhibitor level '" + level + "'");
            }
        }

        function setState(action: string): void {
            if (action === "idle") {
                root.setIdle();
            } else if (action === "wake") {
                root.wake();
            } else if (action === "sleep") {
                root.sleep();
            } else if (action === "suspend") {
                root.suspend();
            } else if (action === "hibernate") {
                root.hibernate();
            } else {
                console.warn("Idle IPC: unknown action '" + action + "'");
            }
        }

        function getState(): string {
            if (lockTimer.triggered) {
                return "sleep";
            } else if (dimTimer.triggered) {
                return "idle";
            } else {
                return "active";
            }
        }

        function getInhibitors(): string {
            return JSON.stringify({
                idle: !persist.enabled,
                lock: persist.inhibitLock,
                suspend: persist.inhibitSuspend,
                respectExternal: persist.respectInhibitors
            });
        }

        signal idleChanged(bool idle)
    }

    PersistentProperties {
        id: persist
        reloadableId: "Idle"

        property bool enabled: true
        property bool respectInhibitors: true
        property bool inhibitLock: false
        property bool inhibitSuspend: false
    }

    IdleMonitor {
        id: dimTimer

        property bool triggered: false
        respectInhibitors: root.respectInhibitors
        enabled: root.enabled

        timeout: 150 // 2.5min

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

        timeout: 180 // 3min

        onIsIdleChanged: {
            if (isIdle) {
                Qt.callLater(() => {
                    root.sleep();
                });
            }
        }
    }
}

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
        suspendTimer.triggered = false;
        dimTimer.triggered = false;
        Brightness.keyboard(true);
        Brightness.restoreScreen();
    }

    function sleep(): void {
        lockTimer.triggered = true;
        Brightness.keyboard(false);
        lock(true);
        Niri.sleepDisplay();
    }

    function suspend(): void {
        suspendTimer.triggered = true;
        if (!lockTimer.triggered) {
            sleep();
        }
        Quickshell.execDetached(["systemctl", "suspend-then-hibernate"]);
    }

    signal lock(bool grace)

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
            } else {
                console.warn("Idle IPC: unknown action '" + action + "'");
            }
        }

        function getState(): string {
            if (suspendTimer.triggered) {
                return "suspend";
            } else if (lockTimer.triggered) {
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

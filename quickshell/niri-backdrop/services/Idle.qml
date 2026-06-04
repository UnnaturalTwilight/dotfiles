// Idle.qml
pragma Singleton

import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.services
import qs.services.niri

Singleton {
    id: root

    property alias enabled: persist.enabled
    property alias respectInhibitors: persist.respectInhibitors
    property alias inhibitSuspend: persist.inhibitSuspend

    function idle(): void {
        Brightness.dimScreen();
        lockTimer.start();
    }

    function wake(): void {
        lockTimer.stop();
        suspendTimer.stop();
        Brightness.restoreScreen();
    }

    function sleep(): void {
        lock();
        Niri.sleepDisplay();
        suspendTimer.start();
    }

    signal lock

    PersistentProperties {
        id: persist
        reloadableId: "Idle"

        property bool enabled: true
        property bool respectInhibitors: true
        property bool inhibitSuspend: false
    }

    IdleMonitor {
        id: idleMonitor
        respectInhibitors: persist.respectInhibitors
        enabled: persist.enabled

        timeout: 150 // 2.5min

        onIsIdleChanged: {
            if (isIdle) {
                root.idle();
            } else {
                root.wake();
            }
        }
    }

    Timer {
        id: lockTimer
        interval: 30000 // 30s
        repeat: false
        running: false

        onTriggered: {
            if (idleMonitor.isIdle) {
                root.sleep();
            }
        }
    }

    Timer {
        id: suspendTimer
        interval: 10000 // 10s
        repeat: false
        running: false

        onTriggered: {
            if (idleMonitor.isIdle && !persist.inhibitSuspend && !Music.playing) {
                Quickshell.execDetached(["systemctl", "sleep"]);
            }
        }
    }
}

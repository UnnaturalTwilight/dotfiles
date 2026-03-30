// Lock.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.utils
import qs.auth

WlSessionLock {
    id: sessionLock

    locked: false

    readonly property int gracePeriodMs: 3000

    function lock(): void {
        Idle.locked = true;
        sessionLock.locked = true;
    }

    function unlock(): void {
        Idle.wake();
        Idle.locked = false;
        sessionLock.locked = false;
    }

    WlSessionLockSurface {
        id: lockSurface
        Lockscreen {
            id: lockScreen
            screen: lockSurface.screen
            lockData: sessionLock
        }
    }
}

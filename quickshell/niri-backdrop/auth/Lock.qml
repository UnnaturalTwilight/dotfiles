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

    signal lockedChanged(bool locked)

    onLockedChanged: {
        lockedChanged(locked);
    }

    readonly property int gracePeriodMs: 3000

    function lock(): void {
        sessionLock.locked = true;
        Idle.screenLocked = true;
    }

    function unlock(): void {
        sessionLock.locked = false;
        Idle.screenLocked = false;
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

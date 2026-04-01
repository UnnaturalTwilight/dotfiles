// Lock.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import QtQuick

import qs.utils
import qs.auth

Scope {
    id: root

    readonly property int gracePeriodMs: 3000
    property bool gracePeriod: false
    property alias locked: sessionLock.secure

    onLockedChanged: {
        lockIPC.lockedChanged(locked);
    }

    function lock(grace = false): void {
        gracePeriod = grace;
        Idle.locked = true;
        sessionLock.locked = true;
    }

    function unlock(): void {
        Idle.wake();
        Idle.locked = false;
        sessionLock.locked = false;
    }

    Connections {
        target: Idle

        function onLock(grace = false): void {
            root.lock(grace);
        }
    }

    IpcHandler {
        id: lockIPC
        target: "lock"

        function lock(): void {
            root.lock(false);
        }

        function unlock(): void {
            root.unlock();
        }

        function state(): bool {
            return root.locked;
        }

        signal lockedChanged(bool locked)
    }

    PamContext {
        id: pam

        // config: "login"
        active: false

        onCompleted: result => {
            // console.log("PAM authentication completed with result: " + result.toString());
            if (result === PamResult.Success) {
                root.unlock();
            }
        }
    }

    WlSessionLock {
        id: sessionLock

        locked: false

        WlSessionLockSurface {
            id: lockSurface
            Lockscreen {
                id: lockScreen
                screen: lockSurface.screen
                lockData: root
                pam: pam
            }
        }
    }
}

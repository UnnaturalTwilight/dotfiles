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

    property alias locked: sessionLock.secure

    onLockedChanged: {
        lockIPC.lockedChanged(locked);
    }

    function lock(): void {
        Idle.locked = true;
        sessionLock.locked = true;
        console.log("Session locked");
    }

    function unlock(): void {
        Idle.wake();
        Idle.locked = false;
        sessionLock.locked = false;
    }

    Connections {
        target: Idle

        function onLock(): void {
            root.lock();
        }
    }

    IpcHandler {
        id: lockIPC
        target: "lock"

        function lock(): void {
            root.lock();
        }

        function unlock(): void {
            root.unlock();
        }

        function status(): bool {
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
                pam: pam
            }
        }
    }
}

// Lock.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import QtQuick

import qs.services

Scope {
    id: root

    property alias locked: sessionLock.secure

    function lock(): void {
        sessionLock.locked = true;
        console.log("[Lock] Session locked");
    }

    function unlock(): void {
        console.log("[Lock] Session unlocked");
        Idle.wake();
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
    }

    PamContext {
        id: pam

        // config: "login"
        active: false

        onCompleted: result => {
            console.log("[Lock][PAM] Authentication completed with result: " + PamResult.toString(result));
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

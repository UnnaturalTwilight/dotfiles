// quickshell/niri-backdrop/shell.qml

import Quickshell
import Quickshell.Io
import QtQuick

import qs.backdrop
import qs.panel
import qs.auth
import qs.utils
import qs.utils.niri

Scope {
    id: root

    Variants {

        model: Quickshell.screens
        Backdrop {}
    }

    // Variants {

    //     model: Quickshell.screens
    //     Debug {}
    // }

    Start {
        id: startPanel
        screen: System.primaryScreen
    }

    Polkit {
        id: polkitAgent
    }

    Lock {
        id: sessionLock
        locked: false
    }

    IpcHandler {
        target: "start"

        function toggle(): void {
            startPanel.toggle();
        }
        function show(): void {
            startPanel.show();
        }
        function hide(): void {
            startPanel.hide();
        }
        function state(): bool {
            return startPanel.shown();
        }
    }

    IpcHandler {
        target: "idle"

        function inhibit(inhibited: bool): void {
            Idle.enabled = !inhibited;
        }
        function respectInhibitors(enabled: bool): void {
            Idle.respectInhibitors = enabled;
        }
        function inhibitLock(enabled: bool): void {
            Idle.inhibitLock = enabled;
        }
        function inhibitSuspend(enabled: bool): void {
            Idle.inhibitSuspend = enabled;
        }
        function inhibited(): bool {
            return !Idle.enabled;
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            sessionLock.lock();
            this.lockedChanged(true);
        }

        function unlock(): void {
            sessionLock.unlock();
            this.lockedChanged(false);
        }

        function state(): bool {
            return sessionLock.locked;
        }

        signal lockedChanged(bool locked)
    }

    Component.onCompleted: {
        Idle.enabled = true;
    }
}

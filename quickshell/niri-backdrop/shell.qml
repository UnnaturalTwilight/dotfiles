// quickshell/niri-backdrop/shell.qml

import Quickshell
import QtQuick

import qs.polkit
import qs.backdrop
import qs.overlay
import qs.lockscreen
import qs.launcher

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens
        Backdrop {}
    }

    Variants {
        model: Quickshell.screens
        Overlay {}
    }

    Launcher {
        id: launcher
        // screen: System.focusedScreen
    }

    Polkit {
        id: polkitAgent
    }

    Lock {
        id: sessionLock
    }
}

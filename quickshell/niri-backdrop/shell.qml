// quickshell/niri-backdrop/shell.qml

import Quickshell
import QtQuick

import qs.polkit
import qs.backdrop
import qs.panel
import qs.services
import qs.overlay
import qs.lockscreen

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
    }
}

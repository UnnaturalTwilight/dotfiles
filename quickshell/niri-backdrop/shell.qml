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
    }

    Component.onCompleted: {
        Idle.enabled = true;
    }
}

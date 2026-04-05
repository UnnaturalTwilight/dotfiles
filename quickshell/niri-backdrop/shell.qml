// quickshell/niri-backdrop/shell.qml

import Quickshell
import Quickshell.Io
import QtQuick

import qs.backdrop
import qs.panel
import qs.auth
import qs.utils
import qs.popup

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

    OSD {
        id: brightnessOsd
        screen: System.primaryScreen
        value: Brightness.screenValue
        icon: "󰃟 "

        Connections {
            target: Brightness

            function onScreenValueChanged() {
                brightnessOsd.showOsd();
            }
        }
    }

    Timer {
        id: loadDelay
        interval: 100
        running: true
        onTriggered: {
            System.suppressOSD = false;
        }
    }
}

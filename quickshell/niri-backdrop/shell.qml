// quickshell/niri-backdrop/shell.qml
import Quickshell
import QtQuick

import qs.backdrop
import qs.panel
import qs.lock

Scope {
    id: root

    Variants {

        model: Quickshell.screens
        Clock {}
    }
    Symbols {}
    Variants {

        model: Quickshell.screens
        Workspaces {}
    }
    // Variants {

    //     model: Quickshell.screens
    //     Debug {}
    // }

    Start {}

    Lockscreen {}
}

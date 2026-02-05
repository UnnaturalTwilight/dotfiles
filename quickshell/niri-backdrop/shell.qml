// quickshell/niri-backdrop/shell.qml
import Quickshell
import QtQuick

import qs.backdrop

Scope {
    id: root

    Variants {

        model: Quickshell.screens
        Clock {}
    }
    Variants {

        model: Quickshell.screens
        Symbols {}
    }
    Variants {

        model: Quickshell.screens
        Workspaces {}
    }
    // Variants {

    //     model: Quickshell.screens
    //     Debug {}
    // }
}

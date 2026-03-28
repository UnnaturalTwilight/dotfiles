// quickshell/niri-backdrop/shell.qml
import Quickshell
import QtQuick

import qs.backdrop
import qs.panel
import qs.auth

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

    Start {}

    Polkit {}
}

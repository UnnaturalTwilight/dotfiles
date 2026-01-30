// quickshell/niri-backdrop/shell.qml
import Quickshell
import QtQuick

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
}

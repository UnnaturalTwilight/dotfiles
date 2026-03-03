// Colours.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property color black: "black"
    readonly property color white: "white"

    readonly property color kindaGray: "#b0b4bc"
    readonly property color darkGray: "#4e4e4e"
    readonly property color bgGray: "#414145"
    readonly property color pinkish: "#D35D6E"
    readonly property color navy: "#38384d"

    readonly property color niri_float: "#007ACC"
    // readonly property color niri_focused: "#FFFFFF"
    readonly property color niri_inactive: "#595959"
    readonly property color niri_urgent: "#fca17d"
}
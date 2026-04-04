// Colours.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // Basic colours
    final readonly property color black: "black"
    final readonly property color white: "white"
    final readonly property color gray: "#b0b4bc"
    final readonly property color text: "#cccccc"

    // New colour palette
    final readonly property color polar0: "#111111"
    final readonly property color polar1: "#1e1e1e"
    final readonly property color polar2: "#393939"
    final readonly property color polar3: "#525252"
    final readonly property color polar4: "#5e5e5e"
    final readonly property color polar5: "#6a6a6a"

    final readonly property color snow0: "#f2f4f7"
    final readonly property color snow1: "#e5e9f0"
    final readonly property color snow2: "#d8dee9"
    final readonly property color snow3: "#cad2e1"
    final readonly property color snow4: "#bdc7da"
    final readonly property color snow5: "#b0bcd3"

    final readonly property color aurora0: "#bf616a"
    final readonly property color aurora1: "#d08770"
    final readonly property color aurora2: "#ebcb8b"
    final readonly property color aurora3: "#a3be8c"
    final readonly property color aurora4: "#c47eba"

    final readonly property color power0: "#9a348e"
    final readonly property color power1: "#da627d"
    final readonly property color power2: "#fca17d"
    final readonly property color power3: "#06969a"
    final readonly property color power4: "#33658a"
    final readonly property color power5: "#38384d"

    final readonly property color mana0: "#7654a8"
    final readonly property color mana1: "#8866bb"
    final readonly property color mana2: "#917bc6"
    final readonly property color mana3: "#aa8ddf"
    final readonly property color mana4: "#af7ccd"

    final readonly property color frost0: "#5e81ac"
    final readonly property color frost1: "#81a1c1"
    final readonly property color frost2: "#86bbd8"
    final readonly property color frost3: "#88c0d0"
    final readonly property color frost4: "#8fbcbb"

    final readonly property color highlight: Qt.alpha(white, 0.15)
    final readonly property color shadow: Qt.alpha(black, 0.40)

}

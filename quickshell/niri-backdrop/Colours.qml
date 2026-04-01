// Colours.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // Basic colours
    readonly property color black: "black"
    readonly property color white: "white"
    readonly property color gray: "#b0b4bc"
    readonly property color text: "#cccccc"
    readonly property color selection: "#264f78"

    // New colour palette
    readonly property color polar0: "#111111"
    readonly property color polar1: "#1e1e1e"
    readonly property color polar2: "#393939"
    readonly property color polar3: "#525252"
    readonly property color polar4: "#5e5e5e"
    readonly property color polar5: "#6a6a6a"

    readonly property color snow0: "#f2f4f7"
    readonly property color snow1: "#e5e9f0"
    readonly property color snow2: "#d8dee9"
    readonly property color snow3: "#cad2e1"
    readonly property color snow4: "#bdc7da"
    readonly property color snow5: "#b0bcd3"

    readonly property color aurora0: "#bf616a"
    readonly property color aurora1: "#d08770"
    readonly property color aurora2: "#ebcb8b"
    readonly property color aurora3: "#a3be8c"
    readonly property color aurora4: "#81a1c1"
    readonly property color aurora5: "#c47eba"
    readonly property color aurora6: "#8866bb"

    readonly property color power0: "#9a348e"
    readonly property color power1: "#da627d"
    readonly property color power2: "#fca17d"
    readonly property color power3: "#86bbd8"
    readonly property color power4: "#06969a"
    readonly property color power5: "#33658a"
    readonly property color power6: "#38384d"

    readonly property color mana0: "#a29ed9"
    readonly property color mana1: "#b69de8"
    readonly property color mana2: "#c092dd"
    readonly property color mana3: "#ae69ce"

    readonly property color frost0: "#8fbcbb"
    readonly property color frost1: "#88c0d0"
    readonly property color frost2: "#81a1c1"
    readonly property color frost3: "#5e81ac"

    readonly property color highlight: Qt.alpha(white, 0.15)
    readonly property color shadow: Qt.alpha(black, 0.40)

}

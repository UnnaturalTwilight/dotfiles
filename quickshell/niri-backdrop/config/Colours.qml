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

    final readonly property color power0: "#9a348e" // Purple
    final readonly property color power1: "#da627d" // Pinkish
    final readonly property color power2: "#fca17d" // Orange
    final readonly property color power3: "#06969a" // Teal
    final readonly property color power4: "#33658a" // Blue
    final readonly property color power5: "#38384d" // Navy

    final readonly property color aurora0: "#bf616a" // Red
    final readonly property color aurora1: "#d08770" // Orange
    final readonly property color aurora2: "#ebcb8b" // Yellow
    final readonly property color aurora3: "#a3be8c" // Green
    final readonly property color aurora4: "#c47eba" // Pink

    final readonly property color mana0: "#7654a8" // Mana Dark
    final readonly property color mana1: "#917bc6" // Aurora Purple / Mana Medium
    final readonly property color mana2: "#aa8ddf" // Mana Bright

    final readonly property color frost0: "#5e81ac" // Frost Dark
    final readonly property color frost1: "#81a1c1" // Aurora Blue / Frost Medium
    final readonly property color frost2: "#88c0d0" // Frost Bright

    final readonly property color snow0: "#b0bcd3" // Snow Dark
    final readonly property color snow1: "#cad2e1" // Snow Medium
    final readonly property color snow2: "#e5e9f0" // Snow Bright

    final readonly property color highlight: Qt.alpha(white, 0.15)
    final readonly property color window: Qt.alpha(black, 0.60)
    final readonly property color shadow: Qt.alpha(black, 0.40)
}

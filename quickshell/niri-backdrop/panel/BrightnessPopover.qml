// BrightnessTile.qml

import Quickshell
import QtQuick

import qs.config

PopupWindow {
    id: brightnessPopover
    property alias tile: brightnessTile

    property real anchorX: 0
    property real anchorY: 0

    anchor.window: startPanel
    anchor.rect.x: anchorX
    anchor.rect.y: anchorY

    color: "transparent"

    property bool menuOpen: false

    implicitWidth: 350
    implicitHeight: 50

    Rectangle {
        id: windowBg
        anchors.fill: parent
        color: Colours.polar1
        radius: 12
        opacity: 0

        states: [
            State {
                name: "open"
                when: brightnessPopover.menuOpen
                PropertyChanges {
                    windowBg.opacity: 1
                }
            },
            State {
                name: "closed"
                when: !brightnessPopover.menuOpen
                PropertyChanges {
                    windowBg.opacity: 0
                }
            }
        ]

        transitions: [
            Transition {
                to: "closed"
                NumberAnimation {
                    properties: "opacity"
                    easing.type: Easing.InQuad
                    duration: 250
                }
            },
            Transition {
                to: "open"
                NumberAnimation {
                    properties: "opacity"
                    easing.type: Easing.OutQuad
                    duration: 250
                }
            }
        ]

        BrightnessTile {
            id: brightnessTile
            anchors.fill: parent
        }
    }

    HoverHandler {
        id: menuHover

        onHoveredChanged: {
            if (hovered) {
                brightnessPopover.stopSelfCloseTimer();
            } else {
                brightnessPopover.startSelfCloseTimer();
            }
        }
    }

    Timer {
        id: selfCloseTimer
        interval: 250
        repeat: false
        running: false
        onTriggered: brightnessPopover.closeSelf()
    }

    Timer {
        id: fadeOutTimer
        interval: 250
        repeat: false
        running: false
        onTriggered: brightnessPopover.visible = false
    }

    function closeSelf(force = false) {
        if (menuHover.hovered && !force) {
            return;
        }
        menuOpen = false;
        fadeOutTimer.start();
    }

    function startSelfCloseTimer() {
        selfCloseTimer.start();
    }

    function stopSelfCloseTimer() {
        selfCloseTimer.stop();
    }

    function open() {
        visible = true;
        menuOpen = true;
    }

    function toggle() {
        if (visible) {
            closeSelf();
        } else {
            open();
        }
    }
}

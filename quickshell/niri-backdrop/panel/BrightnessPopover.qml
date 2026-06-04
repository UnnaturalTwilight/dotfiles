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

    implicitWidth: 350
    implicitHeight: 50

    Rectangle {
        id: windowBg
        anchors.fill: parent
        color: Colours.polar1
        border.color: Colours.frost0
        border.width: 2
        radius: 12
        opacity: 0

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        Component.onCompleted: {
            opacity = 1;
        }

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
        windowBg.opacity = 0;
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
        windowBg.opacity = 1;
    }

    function toggle() {
        if (visible) {
            closeSelf();
        } else {
            open();
        }
    }
}

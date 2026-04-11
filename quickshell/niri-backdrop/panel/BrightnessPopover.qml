// BrightnessTile.qml

import Quickshell
import QtQuick

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

    BrightnessTile {
        id: brightnessTile
        anchors.fill: parent
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
        brightnessTile.opacity = 0;
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
        brightnessTile.opacity = 1;
    }

    function toggle() {
        if (visible) {
            closeSelf();
        } else {
            open();
        }
    }
}

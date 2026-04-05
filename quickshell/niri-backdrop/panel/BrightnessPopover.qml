// BrightnessTile.qml

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.utils
import qs.widgets

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

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
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
        onTriggered: brightnessPopover.closeSelf()
    }

    function closeSelf(force = false) {
        if (menuHover.hovered) {
            return;
        }
        visible = false;
    }

    function startSelfCloseTimer() {
        selfCloseTimer.start();
        brightnessTile.opacity = 0;
    }

    function stopSelfCloseTimer() {
        selfCloseTimer.stop();
        brightnessTile.opacity = 1;
    }

    function open() {
        brightnessTile.opacity = 0;
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

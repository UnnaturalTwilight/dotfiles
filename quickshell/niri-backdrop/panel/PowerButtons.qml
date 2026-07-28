// PowerButtons.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.services
import qs.services.niri
import qs.widgets

ColumnLayout {
    id: powerRow
    spacing: 10
    Layout.alignment: Qt.AlignCenter
    property int buttonSize: 60

    property var colour: "transparent"
    property var borderColour

    property Region blurZone: Region {
        regions: blurRegions.instances
    }

    Variants {
        id: blurRegions
        model: {
            powerRow.visibleChildren;
        }

        delegate: Region {
            required property Item modelData
            item: modelData
            radius: powerRow.buttonSize / 4
        }
    }

    HoldButton {
        symbol: "power/poweroff"
        onActivated: () => {
            Quickshell.execDetached(["systemctl", "poweroff"]);
        }
        buttonSize: powerRow.buttonSize
        bgColor: powerRow.colour
        borderColor: powerRow.borderColour
    }

    HoldButton {
        symbol: "power/restart"
        onActivated: () => {
            Quickshell.execDetached(["systemctl", "reboot"]);
        }
        buttonSize: powerRow.buttonSize
        bgColor: powerRow.colour
        borderColor: powerRow.borderColour
    }

    HoldButton {
        symbol: "power/sleep"
        onActivated: () => {
            Niri.sleepDisplay();
            Qt.callLater(() => {
                System.panelVisible = false;
                Quickshell.execDetached(["systemctl", "sleep"]);
            });
        }
        buttonSize: powerRow.buttonSize
        bgColor: powerRow.colour
        borderColor: powerRow.borderColour
    }

    HoldButton {
        symbol: "power/lock"
        onActivated: () => {
            Idle.lock();
            Qt.callLater(() => {
                System.panelVisible = false;
            });
        }
        buttonSize: powerRow.buttonSize
        bgColor: powerRow.colour
        borderColor: powerRow.borderColour
    }
}

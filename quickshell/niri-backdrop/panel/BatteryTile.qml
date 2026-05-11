// BatteryTile.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qs
import qs.utils
import qs.widgets

InfoTile {
    id: batteryTile
    vSize: 80

    icon: Rectangle {
        implicitHeight: parent.implicitHeight
        implicitWidth: batteryIcon.width
        color: "transparent"

        MultiEffect {
            id: batteryIcon
            source: SvgIcon {
                iconName: Battery.icons[Battery.iconIdx]
                size: 128
            }

            width: 60
            height: 60
            anchors.centerIn: parent

            colorization: 1.0
            colorizationColor: Colours.gray
        }
    }

    info: GridLayout {
        rows: 2
        Layout.alignment: Qt.AlignCenter
        Layout.fillHeight: true
        Layout.fillWidth: true

        Text {
            Layout.row: 0
            Layout.column: 0
            Layout.fillWidth: true
            text: Battery.approxTime
            font.pixelSize: 16
            font.family: Fonts.nerdMono
            color: Colours.white
        }

        Text {
            Layout.row: 0
            Layout.column: 1
            Layout.alignment: Qt.AlignRight
            text: {
                let status = "";
                status += !Idle.respectInhibitors ? "󰾪 " : "";
                status += Idle.inhibitSuspend ? "󱋙 " : "";
                status += Idle.inhibitLock ? "󱙲 " : "";
                status += !Idle.enabled ? "󰒳 " : "";
                return status;
            }
            font.pixelSize: 16
            font.family: Fonts.nerd
            color: Colours.gray
        }

        PercentBar {
            Layout.row: 1
            Layout.column: 0
            Layout.fillWidth: true
            implicitHeight: 12
            value: Battery.value
        }

        Text {
            id: labelText
            Layout.row: 1
            Layout.column: 1
            Layout.alignment: Qt.AlignRight
            text: (Math.round(Battery.value * 100) + "%").padStart(5, " ")
            font.pixelSize: 16
            font.family: Fonts.mono
            color: Colours.text
        }
    }

    onMiddleClicked: () => {
        Idle.enabled = !Idle.enabled;
    }
}

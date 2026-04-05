// BatteryTile.qml

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs
import qs.utils
import qs.widgets

InfoTile {
    id: batteryTile
    vSize: 80

    icon: Text {
        verticalAlignment: Text.AlignVCenter
        text: Battery.icon
        font.pixelSize: 56
        font.family: "JetBrainsMonoNFM"
        color: Colours.gray
    }

    info: GridLayout {
        rows: 2
        Layout.alignment: Qt.AlignCenter
        Layout.fillHeight: true
        Layout.fillWidth: true

        Text {
            Layout.row: 0
            Layout.column: 0
            text: Battery.approxTime
            font.pixelSize: 16
            font.family: "JetBrainsMonoNFM"
            color: Colours.white
        }

        Text {
            Layout.row: 0
            Layout.column: 1
            Layout.alignment: Qt.AlignRight
            text: !Idle.enabled ? "󰒳 " : ""
            font.pixelSize: 16
            font.family: "JetBrainsMonoNF"
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
            font.family: "JetBrainsMonoNFM"
            color: Colours.text
        }
    }

    onMiddleClicked: () => {
        Idle.enabled = !Idle.enabled;
    }
}

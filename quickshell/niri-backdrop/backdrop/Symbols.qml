// Symbols.qml
import QtQuick
import QtQuick.Layouts

import qs
import qs.utils
import qs.widgets

Item {
    id: bgSymbols
    required property var screen

    implicitWidth: sysLayout.implicitWidth
    implicitHeight: sysLayout.implicitHeight

    x: screen?.width - (50 + implicitWidth)
    y: screen?.height - (40 + implicitHeight)

    GridLayout {
        id: sysLayout
        rows: 2
        columnSpacing: 20
        rowSpacing: -5
        flow: GridLayout.TopToBottom

        Text {
            id: audioIcon
            Layout.alignment: Qt.AlignCenter
            text: Audio.icon
            color: Colours.gray
            opacity: Audio.muted ? 0.5 : 1.0
            font.family: "JetBrainsMonoNFM"
            font.pixelSize: Audio.extraProps.iconDisplay[0]
            Layout.bottomMargin: Audio.extraProps.iconDisplay[1]
        }

        PercentBar {
            id: volumeBar
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            value: Audio.volume
            active: !Audio.muted
            implicitWidth: 60
            implicitHeight: 10
        }

        Text {
            id: batteryIcon
            Layout.alignment: Qt.AlignCenter
            text: Battery.icon
            color: Colours.gray
            font.family: "JetBrainsMonoNFM"
            font.pixelSize: 88
            Layout.bottomMargin: -8
        }

        PercentBar {
            id: batteryBar
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            value: Battery.value
            implicitWidth: 60
            implicitHeight: 10
        }
    }
}

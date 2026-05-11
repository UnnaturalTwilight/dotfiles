// Symbols.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

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
        rowSpacing: -3
        flow: GridLayout.TopToBottom

        MultiEffect {
            id: audioIcon
            source: SvgIcon {
                iconName: Audio.icon
                size: 128
            }

            Layout.preferredHeight: Audio.extraProps.iconDisplaySize
            Layout.preferredWidth: Audio.extraProps.iconDisplaySize
            Layout.leftMargin: (60 - Audio.extraProps.iconDisplaySize) / 2
            Layout.rightMargin: (60 - Audio.extraProps.iconDisplaySize) / 2
            Layout.bottomMargin: -14

            colorization: 1.0
            colorizationColor: Colours.gray
            opacity: Audio.muted ? 0.5 : 1.0
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

        MultiEffect {
            id: batteryIcon
            source: SvgIcon {
                iconName: Battery.icons[Battery.iconIdx]
                size: 128
            }

            Layout.preferredHeight: 96
            Layout.preferredWidth: 96
            Layout.leftMargin: -18
            Layout.rightMargin: -18

            colorization: 1.0
            colorizationColor: Colours.gray
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

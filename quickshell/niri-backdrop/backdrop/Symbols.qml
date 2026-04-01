// Symbols.qml
import QtQuick
import QtQuick.Layouts

import qs
import qs.utils

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

        Rectangle {
            // Stretches to fill all left-over space
            Layout.fillWidth: true
            implicitHeight: 10
            implicitWidth: 60
            radius: 20
            color: Colours.polar2

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                implicitWidth: parent.width * Audio.volume
                radius: parent.radius
                color: Colours.power1
                opacity: Audio.muted ? 0.5 : 1.0
            }
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

        Rectangle {
            // Stretches to fill all left-over space
            Layout.fillWidth: true

            implicitHeight: 10
            implicitWidth: 60
            radius: 20
            color: Colours.polar2

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                implicitWidth: parent.width * Battery.value
                radius: parent.radius
                color: Colours.power1
            }
        }
    }
}

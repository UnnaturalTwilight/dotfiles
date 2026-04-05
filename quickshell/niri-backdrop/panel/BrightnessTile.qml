// BrightnessTile.qml

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.utils
import qs.widgets

Rectangle {
    id: brightnessTile
    Layout.fillWidth: true
    Layout.preferredHeight: 40
    radius: 12
    color: hoverBox.containsMouse ? Colours.highlight : "transparent"
    border.color: Colours.polar2
    border.width: 2
    clip: true

    MouseArea {
        id: hoverBox
        anchors.fill: parent
        hoverEnabled: true

        acceptedButtons: Qt.AllButtons
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) {
                Brightness.fetch();
            }
        }

        onWheel: wheel => {
            const step = Math.abs(wheel.angleDelta.y) / 15;
            if (wheel.angleDelta.y > 0) {
                Brightness.setScreen("+" + step + "%");
            } else if (wheel.angleDelta.y < 0) {
                Brightness.setScreen( step + "%-");
            }
            wheel.accepted = true;
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            Text {
                Layout.alignment: Qt.AlignCenter
                Layout.fillHeight: true
                Layout.preferredWidth: 33.6 // width of the icons of the other tiles
                Layout.rightMargin: 8
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "󰃟"
                font.pixelSize: 40
                font.family: "JetBrainsMonoNFM"
                color: Colours.gray
            }

            Slider {
                id: control
                value: Brightness.screenValue
                stepSize: 0.01
                snapMode: Slider.SnapAlways
                wheelEnabled: false
                live: false

                Layout.fillWidth: true

                background: PercentBar {
                    id: volumeBar
                    Layout.row: 1
                    Layout.fillWidth: true
                    implicitHeight: 12
                    value: control.visualPosition
                    active: true
                }
                handle: null

                onMoved: {
                    const v = (Math.max(0.05, control.position)).toFixed(2);
                    Brightness.setScreen(v * 100 + "%");
                }
            }

            Text {
                id: labelText
                Layout.row: 1
                Layout.column: 1
                Layout.alignment: Qt.AlignRight
                text: (Math.round(Brightness.screenValue * 100) + "%").padStart(5, " ")
                font.pixelSize: 16
                font.family: "JetBrainsMonoNFM"
                color: Colours.text
            }
        }
    }
}

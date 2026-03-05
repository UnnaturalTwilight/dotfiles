// PercentBar.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs

Item {
    id: root

    required property real value
    property bool active: true
    property string activeLabel: Math.round(root.value * 100) + "%"
    property string inactiveLabel: activeLabel
    property int labelLength: 4

    RowLayout {
        anchors.fill: parent
        spacing: 12
        Rectangle {
            // Stretches to fill all left-over space
            Layout.fillWidth: true

            implicitHeight: 12
            implicitWidth: 60
            radius: 20
            color: Colours.darkGray

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                implicitWidth: parent.width * root.value
                radius: parent.radius
                color: Colours.pinkish
                opacity: root.active ? 1.0 : 0.5
            }
        }
        Text {
            text: (root.active ? root.activeLabel : root.inactiveLabel).padStart(root.labelLength, " ")
            font.pixelSize: 16
            font.family: "JetBrainsMonoNF"
            color: Colours.white
        }
    }
}

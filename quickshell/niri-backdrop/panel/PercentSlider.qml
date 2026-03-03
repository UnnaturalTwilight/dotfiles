// PercentSlider.qml

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.utils

Item {
    id: root

    required property real value
    property bool active: true
    property string activeLabel: Math.round(root.value * 100) + "%"
    property string inactiveLabel: activeLabel
    property int labelLength: 5
    property var command: null

    RowLayout {
        anchors.fill: parent
        spacing: 12
        Slider {
            id: control
            Layout.fillWidth: true
            from: 0
            to: 1
            value: root.value
            // enabled: root.command !== null
            wheelEnabled: true
            background: Rectangle {
                x: control.leftPadding
                y: control.topPadding + control.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 12
                width: control.availableWidth
                height: implicitHeight
                radius: 20
                color: Colours.darkGray

                Rectangle {
                    width: control.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: Colours.pinkish
                    opacity: root.active ? 1.0 : 0.5
                }
            }
            handle: null
            onValueChanged: root.command ? root.command(value) : null
        }
        Text {
            text: (root.active ? root.activeLabel : root.inactiveLabel).padStart(root.labelLength, " ")
            font.pixelSize: 16
            font.family: "JetBrainsMonoNF"
            color: Colours.white
        }
    }
}

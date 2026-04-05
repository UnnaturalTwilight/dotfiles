// PercentBar.qml
import QtQuick

import qs

Item {
    id: percentBar

    property real value: 0
    property real maximum: 1

    property alias bgColor: bg.color
    property alias fgColor: fg.color

    property bool active: true

    Rectangle {
        id: bg
        anchors.fill: parent
        color: Colours.polar2
        radius: height / 2

        Rectangle {
            id: fg
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            implicitWidth: parent.width * (percentBar.value / percentBar.maximum)
            color: Colours.power1
            radius: parent.radius
            opacity: percentBar.active ? 1.0 : 0.5
        }
    }
}

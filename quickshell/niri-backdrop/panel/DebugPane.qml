// DebugPane.qml

import QtQuick

import qs.config

Rectangle {
    Text {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "?"
    }
    radius: 12
    color: Qt.alpha(Colours.snow0, 0.6)
    border.color: Colours.snow0
    border.width: 2
}

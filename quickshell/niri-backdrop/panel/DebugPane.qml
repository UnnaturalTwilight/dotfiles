// DebugPane.qml

import QtQuick

import qs.config
import qs.services

Rectangle {
    Text {
        anchors.fill: parent
        anchors.margins: 10
        // horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: JSON.stringify("DEBUG", null, 1)
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        width: 400
    }
    radius: 12
    color: Qt.alpha(Colours.snow0, 0.6)
    border.color: Colours.snow0
    border.width: 2
}

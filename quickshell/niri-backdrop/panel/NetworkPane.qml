// NetworkPane.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services

Rectangle {
    id: notifications
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.preferredHeight: childrenRect.height

    color: Colours.blurPane
    border.color: Colours.power5
    border.width: 2
    radius: 12

    Text {
        text: Network.connectionString + "\t" + Network.signalStrength
        color: Colours.text
        font.family: Fonts.sans
        font.pixelSize: 20
        padding: 8
    }
}

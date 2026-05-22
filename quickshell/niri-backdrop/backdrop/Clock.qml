// Clock.qml

import QtQuick

import qs
import qs.utils

Item {
    id: bgClock
    required property var screen

    implicitWidth: timeText.implicitWidth

    x: screen?.width - (50 + implicitWidth)
    y: 30

    Text {
        id: timeText
        anchors.horizontalCenter: parent.horizontalCenter
        text: Time.time
        color: Colours.gray
        font.pixelSize: 128
        font.family: Fonts.mono
    }

    Text {
        id: dateText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: timeText.bottom
        anchors.topMargin: -24
        text: Time.date
        color: Colours.gray
        font.pixelSize: 24
        font.family: Fonts.sans
    }
}

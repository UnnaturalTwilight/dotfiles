// Clock.qml

import QtQuick
import QtQuick.Layouts

import qs
import qs.utils

Item {
    id: bgClock
    required property var screen

    implicitWidth: clockLayout.implicitWidth
    implicitHeight: clockLayout.implicitHeight

    x: screen?.width - (50 + implicitWidth)
    y: 30

    ColumnLayout {
        id: clockLayout
        spacing: -24

        Text {
            id: timeText
            Layout.alignment: Qt.AlignCenter
            text: Time.time
            color: Colours.gray
            font.pixelSize: 128
            font.family: Fonts.nerdMono
        }

        Text {
            id: dateText
            Layout.alignment: Qt.AlignCenter
            text: Time.date
            color: Colours.gray
            font.pixelSize: 24
            font.family: "Noto Sans"
        }
    }
}

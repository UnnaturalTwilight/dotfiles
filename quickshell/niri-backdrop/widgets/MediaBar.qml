// MediaBar.qml

import QtQuick
import QtQuick.Layouts

import qs
import qs.utils
import qs.widgets

Rectangle {
    id: mediaBar
    width: layout.implicitWidth + 30
    height: 50
    radius: height / 2
    color: Colours.highlight

    RowLayout {
        id: layout
        anchors {
            margins: 5
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        spacing: 10

        Rectangle {
            id: playpauseButton
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: height / 2
            color: playPauseMouseArea.containsMouse ? Colours.highlight : "transparent"
            SvgIcon {
                iconName: Music.playing ? "pause" : "play"
                size: 40
                anchors.centerIn: parent
            }

            MouseArea {
                id: playPauseMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Music.toggle()
            }
        }

        Text {
            id: mediaInfo
            Layout.fillWidth: true
            text: Music.title + " — " + Music.artist ?? "Not Playing"
            font.pixelSize: 18
            font.family: Fonts.mono
            color: Colours.white
            verticalAlignment: Text.AlignVCenter
        }
    }
}

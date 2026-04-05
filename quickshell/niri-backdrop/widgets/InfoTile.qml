// InfoTile.qml

import QtQuick
import QtQuick.Layouts

import qs

Item {
    id: root
    required property Component icon
    required property Component info
    required property int vSize

    Layout.fillWidth: true
    Layout.preferredHeight: vSize
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    property int margins: 16

    signal leftClicked
    signal rightClicked
    signal middleClicked

    Rectangle {
        anchors.fill: parent
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
                if (mouse.button === Qt.LeftButton) {
                    root.leftClicked();
                } else if (mouse.button === Qt.RightButton) {
                    root.rightClicked();
                } else if (mouse.button === Qt.MiddleButton) {
                    root.middleClicked();
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: root.margins
                spacing: root.margins

                Loader {
                    id: iconLoader
                    Layout.fillHeight: true
                    Layout.preferredWidth: iconLoader.width
                    sourceComponent: root.icon
                }

                Loader {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.rightMargin: 0
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                    sourceComponent: root.info
                }
            }
        }
    }
}

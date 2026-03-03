// InfoTile.qml

import QtQuick
import QtQuick.Layouts

import qs

Item {
    id: root
    required property Component icon
    required property Component info
    Layout.fillWidth: true
    required property int vSize
    Layout.preferredHeight: vSize
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    property int margins: 16

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: hoverBox.containsMouse ? Qt.alpha(Colours.white, 0.1) : "transparent"
        border.color: hoverBox.containsMouse ? Qt.alpha(Colours.pinkish, 0.5) : Qt.alpha(Colours.kindaGray, 0.5)
        border.width: 3
        clip: true

        MouseArea {
            id: hoverBox
            anchors.fill: parent
            hoverEnabled: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: root.margins
                spacing: root.margins

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: iconLoader.implicitWidth

                    Loader {
                        id: iconLoader
                        anchors.centerIn: parent
                        sourceComponent: root.icon
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.rightMargin: 0
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                    Loader {
                        anchors.fill: parent
                        sourceComponent: root.info
                    }
                }
            }
        }
    }
}

// Panels.qml

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services
import qs.panel

Item {
    id: panels
    // required property var screen
    property int margin: 10
    property int radius: 12
    property int buttonWidth: 60

    anchors {
        top: parent.top
        right: parent.right
        bottom: parent.bottom
        rightMargin: margin
        topMargin: margin
        bottomMargin: margin
    }
    implicitWidth: 550 - (2 * margin)

    property Region blurZone: Region {
        Region {
            item: tabContentZone
            radius: panels.radius
        }
        Region {
            item: tileZone
            radius: panels.radius
        }
    }

    property Region maskZone: Region {
        Region {
            item: statusZone
        }
        Region {
            x: panels.x + panels.buttonWidth
            y: panels.y - panels.margin
            width: tileZone.width + (3 * panels.margin)
            height: panels.height + (2 * panels.margin)
        }
        Region {
            x: panels.x - (panels.margin / 2)
            y: tabButtons.y - (panels.margin)
            width: panels.buttonWidth + (2 * panels.margin)
            height: tabButtons.implicitHeight + (3 * panels.margin)
        }
        Region {
            x: panels.x - (panels.margin / 2)
            y: powerButtons.y
            width: panels.buttonWidth + (2 * panels.margin)
            height: powerButtons.implicitHeight + (2 * panels.margin)
        }
    }

    Statusline {
        id: statusZone
        margin: panels.margin
        radius: panels.radius

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            leftMargin: -40 //panels.margin
            // rightMargin: panels.margin
        }
    }

    TabButtons {
        id: tabButtons
        buttonSize: panels.buttonWidth
        bgColour: Colours.power5

        anchors {
            top: statusZone.bottom
            topMargin: panels.margin * 2
            left: parent.left
        }
    }

    StackLayout {
        id: tabContentZone
        anchors {
            top: statusZone.bottom
            topMargin: panels.margin
            left: powerButtons.right
            leftMargin: panels.margin
            right: statusZone.right
            // rightMargin: panels.margin
            bottom: tileZone.top
            bottomMargin: panels.margin
        }

        currentIndex: System.panelTab

        NotifPane {
            radius: panels.radius
        }

        Rectangle {
            color: Colours.aurora2
            implicitWidth: 300
            implicitHeight: 200
            radius: panels.radius
        }
        Rectangle {
            color: Colours.aurora3
            implicitWidth: 200
            implicitHeight: 200
            radius: panels.radius
        }

        DebugPane {}
    }

    Rectangle {
        id: tileZone
        anchors {
            left: powerButtons.right
            leftMargin: panels.margin
            right: statusZone.right
            // rightMargin: panels.margin
            bottom: parent.bottom
            // bottomMargin: panels.margin
        }
        radius: panels.radius
        implicitHeight: 320

        color: Qt.alpha(Colours.power5, 0.6)
        border.color: Colours.power5
        border.width: 2

        ColumnLayout {
            id: tiles
            anchors {
                left: tileZone.left
                leftMargin: panels.margin
                right: tileZone.right
                rightMargin: panels.margin
                top: tileZone.top
                topMargin: panels.margin
                bottom: tileZone.bottom
                bottomMargin: panels.margin
                margins: 20
            }
            spacing: 12

            SysTray {
                id: systray
                menuWidth: 400
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
            }

            AudioTile {}

            BatteryTile {}
        }
    }

    PowerButtons {
        id: powerButtons
        buttonSize: panels.buttonWidth
        colour: Colours.power5 //Qt.alpha(Colours.power5, 0.6)
        borderColour: Colours.frost0

        anchors {
            bottom: parent.bottom
            bottomMargin: panels.margin * 1.5
            left: parent.left
        }
    }
}

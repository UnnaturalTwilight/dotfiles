// Panels.qml

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.elements
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
        // Region {
        //     item: statusZone
        //     radius: panels.radius
        // }
        Region {
            item: mainZone
            radius: panels.radius
        }
        // Region {
        //     regions: buttons.blurZone
        // }
    }

    property Region maskZone: Region {
        Region {
            item: statusZone
            // radius: panels.radius
        }
        Region {
            x: panels.x + panels.buttonWidth
            y: panels.y - panels.margin
            width: mainZone.width + (3 * panels.margin)
            height: panels.height + (2 * panels.margin)
            // radius: panels.radius
        }
        Region {
            x: panels.x - (panels.margin /2)
            y: buttons.y
            width: panels.buttonWidth + (2 * panels.margin)
            height: buttons.implicitHeight + (2 * panels.margin)
            // radius: panels.radius
        }
        Region {
            // intersection: Intersection.Subtract
            // x: panels.x
            // y: panels.y
            // width: panels.buttonWidth
            // height: parent.height
            // radius: panels.radius
        }
    }

    Rectangle {
        id: statusZone

        implicitHeight: 30
        radius: panels.radius

        color: Colours.power5 //Qt.alpha(Colours.power5, 0.6)
        border.color: Colours.frost0
        border.width: 2

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            leftMargin: -40 //panels.margin
            // rightMargin: panels.margin
        }

        Text {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: panels.margin
            text: Time.time
            color: Colours.gray
            font.pixelSize: 20
            font.family: Fonts.mono
        }

        Text {
            id: dateText
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: timeText.left
            anchors.rightMargin: panels.margin
            text: Time.isoDate
            color: Colours.gray
            font.pixelSize: 20
            font.family: Fonts.mono
        }

        Text {
            id: networkIcon
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: dateText.left
            anchors.rightMargin: panels.margin
            text: Network?.connectionIcon ?? ""
            color: Colours.gray
            font.pixelSize: 20
            font.family: Fonts.mono
        }

        Text {
            id: userText
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: statusZone.left
            anchors.leftMargin: panels.margin
            text: "󰣇 " + System.username + "@" + System.hostname
            color: Colours.gray
            font.pixelSize: 20
            font.family: Fonts.mono
        }
    }

    Rectangle {
        id: mainZone
        anchors {
            top: statusZone.bottom
            topMargin: panels.margin
            left: buttons.right
            leftMargin: panels.margin
            right: statusZone.right
            // rightMargin: panels.margin
            bottom: parent.bottom
            // bottomMargin: panels.margin
        }
        radius: panels.radius

        color: Qt.alpha(Colours.power5, 0.6)
        border.color: Colours.power5
        border.width: 2

        NotificationList {
            id: notifications
            anchors {
                top: mainZone.top
                topMargin: panels.margin
                left: mainZone.left
                leftMargin: panels.margin
                right: mainZone.right
                rightMargin: panels.margin
                bottom: tiles.top
                bottomMargin: panels.margin
                margins: 20
            }
            color: Qt.alpha(Colours.polar0, 0.4)
        }

        ColumnLayout {
            id: tiles
            anchors {
                left: mainZone.left
                leftMargin: panels.margin
                right: mainZone.right
                rightMargin: panels.margin
                bottom: mainZone.bottom
                bottomMargin: panels.margin
                margins: 20
            }
            spacing: 12

            AudioTile {}

            BatteryTile {}
        }
    }

    PowerButtons {
        id: buttons
        buttonSize: panels.buttonWidth
        colour: Colours.power5 //Qt.alpha(Colours.power5, 0.6)
        borderColour: Colours.frost0

        anchors {
            bottom: parent.bottom
            bottomMargin: panels.margin * 1.5
            left: parent.left
            // leftMargin: panels.margin / 2
        }
    }
}

// NotifPane.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services.notifications
import qs.widgets

Rectangle {
    id: notifications
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.preferredHeight: childrenRect.height

    color: Colours.blurPane
    border.color: Colours.power5
    border.width: 2
    radius: 12

    property int margin: 10

    Text {
        id: label
        text: "Notifications"
        color: Colours.text
        verticalAlignment: Text.AlignVCenter
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: margin * 2
            margins: notifications.margin
        }
        font.family: Fonts.mono
        font.pixelSize: 20
    }

    FlatButton {
        id: dismissAll
        text: "Dismiss all"

        anchors {
            verticalCenter: label.verticalCenter
            right: dnd.left
            margins: notifications.margin
        }
        implicitWidth: 120
        implicitHeight: 30

        enabled: NotifServer.list.length > 0
        radius: parent.radius / 2

        onClicked: NotifServer.clearAll();
    }

    FlatButton {
        id: dnd
        text: ""

        anchors {
            verticalCenter: label.verticalCenter
            right: parent.right
            margins: notifications.margin
        }
        implicitWidth: 30
        implicitHeight: 30

        radius: parent.radius / 2

        contentItem: SvgIcon {
            anchors.centerIn: parent
            iconName: "notifications" + (NotifServer.doNotDisturb ? "_off" : "")
            colour: parent.hovered ? Colours.snow2 : Colours.snow0
        }

        onClicked: NotifServer.doNotDisturb = !NotifServer.doNotDisturb;
    }


    ListView {
        id: notificationList
        clip: true

        anchors {
            top: label.bottom
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            margins: notifications.margin
        }
        implicitWidth: parent.width - notifications.margin * 2
        implicitHeight: parent.height - dismissAll.height - notifications.margin * 3
        spacing: notifications.margin

        model: ScriptModel {
            values: NotifServer.list.filter(n => !n.closed)
        }

        delegate: Notification {
            implicitWidth: parent?.width ?? 300
        }

        add: Transition {
            NumberAnimation {
                properties: "x"
                from: 400
                duration: 250
            }
        }

        addDisplaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 250
            }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 250
                }
                NumberAnimation {
                    properties: "x"
                    to: 400
                    duration: 250
                }
            }
        }

        removeDisplaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 250
            }
        }
    }
}

// NotificationList.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

import qs
import qs.utils.notify
import qs.overlay

Rectangle {
    id: notifications
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.preferredHeight: childrenRect.height

    color: Colours.polar0
    radius: 20

    property int gap: 8
    property int iconSize: 32
    property int fontSize: 18

    ClippingRectangle {
        color: "transparent"

        anchors {
            top: dismissAll.bottom
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            margins: notifications.gap
        }
        implicitWidth: parent.width - notifications.gap * 2
        implicitHeight: parent.height - dismissAll.height - notifications.gap * 3
        radius: 16

        ListView {
            id: notificationList

            anchors.fill: parent
            spacing: notifications.gap

            model: ScriptModel {
                values: Notify.list.filter(n => !n.temporary)
            }

            delegate: Notification {
                implicitWidth: parent?.width ?? 300
                // color: Colours.polar1
            }
        }
    }

    Text {
        id: label
        text: "Notifications"
        color: Colours.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors {
            verticalCenter: dismissAll.verticalCenter
            left: parent.left
            right: dismissAll.left
            margins: notifications.gap
        }
        font.family: Fonts.mono
        font.pixelSize: 16
    }

    Rectangle {
        id: dismissAll

        anchors {
            top: parent.top
            right: dnd.left
            margins: notifications.gap
        }

        implicitWidth: 120
        implicitHeight: 30

        property bool active: Notify.list.length > 0
        color: dismissAllMouseArea.containsMouse ? Colours.highlight : "transparent"
        Text {
            text: "Dismiss all"
            color: dismissAllMouseArea.containsMouse ? Colours.power1 : dismissAll.active ? Colours.text : Colours.polar5
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            font.family: Fonts.sans
            font.pixelSize: 16
        }
        border.color: Colours.polar2
        border.width: 3
        radius: 12
        MouseArea {
            id: dismissAllMouseArea
            anchors.fill: parent
            hoverEnabled: dismissAll.active
            enabled: dismissAll.active
            onClicked: {
                Notify.clearAll();
            }
        }
    }

    Rectangle {
        id: dnd

        anchors {
            top: parent.top
            right: parent.right
            margins: notifications.gap
        }

        implicitWidth: 50
        implicitHeight: 30

        color: dndMouseArea.containsMouse ? Colours.highlight : "transparent"
        Text {
            text: Notify.doNotDisturb ? "󰂛" : "󰂚"
            color: dndMouseArea.containsMouse ? Colours.power1 : Colours.text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
            font.family: Fonts.nerd
            font.pixelSize: 16
        }
        border.color: Colours.polar2
        border.width: 3
        radius: 12
        MouseArea {
            id: dndMouseArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: true
            onClicked: {
                Notify.doNotDisturb = !Notify.doNotDisturb;
            }
        }
    }
}

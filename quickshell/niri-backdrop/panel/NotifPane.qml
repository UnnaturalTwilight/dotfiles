// NotifPane.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services.notifications

Rectangle {
    id: notifications
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.preferredHeight: childrenRect.height

    color: Qt.alpha(Colours.power5, 0.6)
    border.color: Colours.power5
    border.width: 2
    radius: 12

    NotificationList {
        anchors.fill: parent
        color: "transparent"
        radius: parent.radius
    }
}

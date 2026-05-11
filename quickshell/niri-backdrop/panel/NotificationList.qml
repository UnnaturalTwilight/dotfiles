// NotificationList.qml
pragma ComponentBehavior: Bound

import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

import qs
import qs.utils
import qs.overlay

ColumnLayout {
    id: notifications
    Layout.fillHeight: true
    Layout.preferredHeight: childrenRect.height
    Layout.margins: gap
    spacing: gap

    property int gap: 8
    property int iconSize: 32
    property int fontSize: 18

    Repeater {
        model: Notify.tracked.values

        Notification {
            implicitWidth: parent?.width ?? 300
        }
    }

    Rectangle {
        id: dismissAll
        Layout.fillWidth: true
        Layout.preferredHeight: 30
        // visible: Notify.tracked.values.length > 0
        property bool active: Notify.tracked.values.length > 0
        color: dismissAllMouseArea.containsMouse ? Colours.highlight : "transparent"
        Text {
            text: "Dismiss all"
            color: dismissAllMouseArea.containsMouse ? Colours.power1 : dismissAll.active ? Colours.text : Colours.polar5
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
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
                while (Notify.tracked.values.length > 0) {
                    Notify.tracked.values[0].dismiss();
                }
            }
        }
    }
}

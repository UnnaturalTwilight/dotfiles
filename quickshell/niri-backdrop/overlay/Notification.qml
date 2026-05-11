// Notification.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs
import qs.widgets

Rectangle {
    id: root

    required property Notification modelData
    property int padding: 10
    property int iconSize: 48
    property int fontSize: 18

    implicitHeight: notificationContent.childrenRect.height + (padding * 2)
    implicitWidth: 400
    radius: 20
    color: Colours.shadow
    border.color: modelData.urgency === NotificationUrgency.Critical ? Colours.power1 : Colours.frost0
    border.width: 2

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) {
                root.modelData.dismiss();
            }
        }
    }

    SvgIcon {
        id: closeButton
        iconName: "close"
        size: 24

        x: root.width - (root.padding + width)
        y: root.padding

        opacity: notificationDismissMouseArea.containsMouse ? 1 : 0.7

        MouseArea {
            id: notificationDismissMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.modelData.dismiss()
        }
    }

    RowLayout {
        id: notificationContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.padding
        spacing: root.padding

        ColumnLayout {
            visible: root.modelData.appIcon !== "" || root.modelData.image !== ""
            Layout.alignment: Qt.AlignTop

            Image {
                source: Quickshell.iconPath(root.modelData.appIcon, true)
                sourceSize: Qt.size(root.iconSize, root.iconSize)
                Layout.maximumWidth: root.iconSize
                Layout.maximumHeight: root.iconSize
                visible: root.modelData.appIcon !== ""
            }

            Image {
                source: root.modelData.image
                sourceSize: Qt.size(root.iconSize, root.iconSize)
                Layout.maximumWidth: root.iconSize
                Layout.maximumHeight: root.iconSize
                visible: root.modelData.image !== ""
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true

                text: root.modelData.appName
                wrapMode: Text.Wrap
                Layout.maximumWidth: 350
                font {
                    family: Fonts.sans
                    pixelSize: root.fontSize
                    bold: true
                }
                color: Colours.snow2
            }

            Text {
                Layout.fillWidth: true

                text: root.modelData.summary
                wrapMode: Text.Wrap
                Layout.maximumWidth: 350
                font {
                    family: Fonts.sans
                    pixelSize: root.fontSize
                }
                color: Colours.snow2
            }

            Text {
                Layout.fillWidth: true

                text: root.modelData.body
                wrapMode: Text.Wrap
                visible: root.modelData.body !== ""
                Layout.maximumWidth: 350
                font {
                    family: Fonts.sans
                    pixelSize: root.fontSize
                }
                color: Colours.snow2
            }

            PercentBar {
                Layout.fillWidth: true
                visible: root.modelData.hints.value !== undefined
                value: root.modelData.hints.value / 100

                implicitHeight: 12
            }

            RowLayout {
                id: actionsRow
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: root.padding
                visible: root.modelData.actions.length > 0

                Repeater {
                    model: root.modelData.actions

                    delegate: Action {}
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.maximumWidth: 400
                visible: root.modelData.hasInlineReply
                border.color: notificationInlineReplyMouseArea.containsMouse ? Colours.frost2 : Colours.frost0
                TextField {
                    id: notificationInlineReplyTextField
                    anchors.fill: parent
                    background: null
                    color: Colours.polar4
                    placeholderTextColor: Colours.polar1
                    font {
                        family: Fonts.sans
                        pixelSize: root.fontSize
                    }
                    Layout.fillWidth: true
                    placeholderText: root.modelData.inlineReplyPlaceholder
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                }
                Item {
                    anchors {
                        right: parent.right
                        rightMargin: root.padding
                        verticalCenter: parent.verticalCenter
                    }
                    implicitWidth: root.fontSize + root.padding
                    implicitHeight: root.fontSize + root.padding
                    Text {
                        text: ""
                        color: notificationInlineReplyMouseArea.containsMouse ? Colours.highlight : Colours.polar4
                    }
                    MouseArea {
                        id: notificationInlineReplyMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.modelData.sendInlineReply(notificationInlineReplyTextField.text)
                    }
                }
            }
        }
    }

    component Action: Rectangle {
        id: actionRoot
        required property var modelData

        implicitHeight: root.fontSize + root.padding
        Layout.maximumWidth: actionContent.childrenRect.width + (root.padding * 6)
        Layout.fillWidth: true
        color: Colours.shadow
        radius: 8
        border.color: notificationActionMouseArea.containsMouse ? Colours.power1 : Colours.polar2
        RowLayout {
            id: actionContent
            anchors.centerIn: parent
            spacing: root.padding
            Image {
                source: root.modelData.hasActionIcons ? actionRoot.modelData.identifier : ""
                sourceSize.width: root.iconSize / 2
                sourceSize.height: root.iconSize / 2
                Layout.maximumWidth: root.iconSize / 2
                Layout.maximumHeight: root.iconSize / 2
                visible: root.modelData.hasActionIcons
            }
            Text {
                Layout.fillWidth: true
                text: actionRoot.modelData.text.trim() != "" ? actionRoot.modelData.text : "Action"
                color: notificationActionMouseArea.containsMouse ? Colours.white : Colours.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
            }
        }
        MouseArea {
            id: notificationActionMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: actionRoot.modelData.invoke()
        }
    }
}

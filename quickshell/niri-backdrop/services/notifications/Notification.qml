// Notification.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.config
import qs.widgets

Rectangle {
    id: root

    required property NotifData modelData
    property int padding: 10
    property int iconSize: 48
    property int fontSize: 18

    implicitHeight: notificationContent.childrenRect.height + (padding * 2)
    implicitWidth: 400
    radius: 20
    color: Colours.shadow
    border.color: modelData?.urgency === NotificationUrgency.Critical ? Colours.power1 : Colours.frost0
    border.width: 2

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) {
                root.modelData?.close();
            } else if (mouse.button === Qt.LeftButton) {
                root.modelData?.defaultAction();
            } else if (mouse.button === Qt.RightButton) {
                root.modelData?.dismiss();
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
            onClicked: root.modelData?.close()
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
            Layout.alignment: Qt.AlignTop

            Image {
                source: root.modelData.appIcon || Quickshell.iconPath("preferences-desktop-notification")
                sourceSize: Qt.size(root.iconSize, root.iconSize)
                Layout.maximumWidth: root.iconSize
                Layout.maximumHeight: root.iconSize
                visible: root.modelData?.appIcon !== "" || root.modelData?.image === ""
            }

            Image {
                source: root.modelData.image ?? ""
                sourceSize: Qt.size(root.iconSize, root.iconSize)
                Layout.maximumWidth: root.iconSize
                Layout.maximumHeight: root.iconSize
                visible: root.modelData?.image !== ""
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            Text {
                text: root.modelData?.appName || "Notification"

                Layout.fillWidth: true
                Layout.maximumWidth: 350
                font {
                    family: Fonts.sans
                    pixelSize: root.fontSize
                    bold: true
                }
                wrapMode: Text.Wrap
                color: Colours.snow2
            }

            Text {
                text: root.modelData?.summary ?? ""
                visible: root.modelData?.summary !== ""

                Layout.fillWidth: true
                Layout.maximumWidth: 350
                font {
                    family: Fonts.sans
                    pixelSize: root.fontSize
                }
                wrapMode: Text.Wrap
                color: Colours.snow2
            }

            Text {
                text: root.modelData?.body ?? ""
                visible: root.modelData?.body !== ""

                Layout.fillWidth: true
                Layout.maximumWidth: 350
                font {
                    family: Fonts.sans
                    pixelSize: root.fontSize
                }
                wrapMode: Text.Wrap
                color: Colours.snow2
            }

            PercentBar {
                Layout.fillWidth: true
                visible: root.modelData?.hasProgress
                value: root.modelData?.progress ?? 0

                implicitHeight: 12

                Behavior on value {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.Linear
                    }
                }
            }

            RowLayout {
                id: actionsRow
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: root.padding
                visible: root.modelData?.actions.length > 0

                Repeater {
                    model: root.modelData?.actions

                    delegate: Action {}
                }
            }

            Rectangle {
                Layout.fillWidth: true
                // Layout.maximumWidth: 400
                Layout.preferredHeight: root.fontSize + root.padding
                visible: root.modelData?.hasInlineReply === true
                color: Colours.shadow
                border.color: notificationInlineReplyTextField.activeFocus ? Colours.power1 : Colours.polar2
                border.width: 2
                radius: 8
                TextField {
                    id: notificationInlineReplyTextField
                    anchors.fill: parent
                    background: null
                    color: Colours.text
                    placeholderTextColor: Colours.snow0
                    font.family: Fonts.sans
                    Layout.fillWidth: true
                    placeholderText: root.modelData?.inlineReplyPlaceholder ?? "Reply..."
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap

                    Keys.onPressed: function (event) {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.modelData?.notification?.sendInlineReply(notificationInlineReplyTextField.text)
                            event.accepted = true;
                        }
                    }
                }
                Item {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    implicitWidth: root.fontSize + root.padding
                    implicitHeight: root.fontSize + root.padding
                    Text {
                        anchors.centerIn: parent
                        text: "󰒊"
                        color: Colours.white
                        opacity: notificationInlineReplyMouseArea.containsMouse ? 1 : 0.7
                        font.family: Fonts.nerdMono
                        font.pixelSize: root.fontSize * 1.25

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.Linear
                            }
                        }
                    }
                    MouseArea {
                        id: notificationInlineReplyMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.modelData?.notification?.sendInlineReply(notificationInlineReplyTextField.text)
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
        Layout.preferredWidth: actionContent.childrenRect.width + (root.padding * 2)
        Layout.fillWidth: true
        color: Colours.shadow
        radius: 8
        border.color: notificationActionMouseArea.containsMouse ? Colours.power1 : Colours.polar2
        border.width: 2
        RowLayout {
            id: actionContent
            anchors.centerIn: parent
            spacing: root.padding
            Image {
                source: Quickshell.iconPath(actionRoot.modelData.identifier, true)
                sourceSize.width: root.iconSize / 2
                sourceSize.height: root.iconSize / 2
                Layout.maximumWidth: root.iconSize / 2
                Layout.maximumHeight: root.iconSize / 2
                visible: root.modelData.hasActionIcons && source.toString() !== ""
            }
            Text {
                Layout.fillWidth: true
                text: actionRoot.modelData.text.trim() != "" ? actionRoot.modelData.text : "Action"
                color: notificationActionMouseArea.containsMouse ? Colours.white : Colours.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
                font.family: Fonts.sans
                font.italic: actionRoot.modelData.text.trim() == ""
                font.bold: actionRoot.modelData?.default ?? false
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

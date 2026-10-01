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
        cursorShape: bodyText.hoveredLink != "" ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.AllButtons
        onClicked: mouse => {
            switch (mouse.button) {
                case Qt.MiddleButton:
                    root.modelData?.close();
                    break;
                case Qt.LeftButton:
                    root.modelData?.defaultAction();
                    break;
                case Qt.RightButton:
                    root.modelData?.dismiss();
                    break;
            }
        }
    }

    Text {
        id: timestampText
        text: Qt.formatDateTime(root.modelData?.timestamp, "hh:mm");

        anchors {
            right: closeButton.left
            rightMargin: root.padding
            verticalCenter: closeButton.verticalCenter
        }

        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignBottom
        font {
            family: Fonts.mono
            pixelSize: root.fontSize - 4
        }
        textFormat: Text.PlainText
        color: Colours.gray
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

            // Text {
            //     id: timestampText
            //     text: Qt.formatDateTime(root.modelData?.timestamp, "hh:mm");
            //     Layout.fillWidth: true
            //     Layout.fillHeight: true
            //     Layout.maximumWidth: root.iconSize
            //     horizontalAlignment: Qt.AlignHCenter
            //     verticalAlignment: Qt.AlignBottom
            //     font {
            //         family: Fonts.mono
            //         pixelSize: root.fontSize - 4
            //     }
            //     textFormat: Text.PlainText
            //     color: Colours.gray
            // }
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
                textFormat: Text.PlainText
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
                textFormat: Text.StyledText
                color: Colours.snow2
            }

            Text {
                id: bodyText
                text: root.modelData?.body ?? ""
                visible: root.modelData?.body !== ""

                Layout.fillWidth: true
                Layout.maximumWidth: 350
                font {
                    family: Fonts.sans
                    pixelSize: root.fontSize
                }
                wrapMode: Text.Wrap
                textFormat: root.modelData?.appName == "discord" ? Text.MarkdownText : Text.StyledText
                color: Colours.snow2
                linkColor: Colours.frost2

                onLinkActivated: link => Quickshell.execDetached(["xdg-open", link])
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
                    model: root.modelData?.actions.filter(a => a.display)

                    delegate: FlatButton {
                        id: actionRoot
                        required property var modelData
                        text: actionRoot.modelData.text.trim() || "Action"
                        implicitHeight: root.fontSize + root.padding
                        Layout.maximumWidth: implicitWidth + (root.padding * 6)
                        Layout.preferredWidth: implicitWidth + (root.padding * 2)
                        Layout.fillWidth: true
                        radius: 8

                        font {
                            family: Fonts.sans
                            pixelSize: root.fontSize
                            italic: actionRoot.modelData.text.trim() == ""
                            bold: actionRoot.modelData?.default ?? false
                        }

                        leftPadding: actionIcon.visible ? actionIcon.width : 0

                        Image {
                            id: actionIcon
                            source: Quickshell.iconPath(actionRoot.modelData.identifier, true)
                            sourceSize.width: root.iconSize / 2
                            sourceSize.height: root.iconSize / 2
                            height: root.iconSize / 2
                            width: root.iconSize / 2

                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: root.padding / 2
                                rightMargin: root.padding / 2
                            }

                            visible: root.modelData.hasActionIcons && source.toString() !== ""
                        }

                        onClicked: actionRoot.modelData.invoke()
                    }
                }
            }

            TextField {
                id: notifInlineReplyTextField
                visible: root.modelData?.hasInlineReply === true

                Layout.preferredHeight: (contentHeight) + root.padding
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                color: Colours.text
                placeholderTextColor: Colours.snow0
                placeholderText: root.modelData?.inlineReplyPlaceholder ?? "Reply..."
                font.family: Fonts.sans
                wrapMode: Text.Wrap

                leftPadding: root.padding
                rightPadding: notifInlineReplySend.width + (root.padding / 2)

                onPressed: root.modelData?.timer.stop()
                Keys.onPressed: function (event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.modelData?.notification?.sendInlineReply(notifInlineReplyTextField.text);
                        event.accepted = true;
                    }
                }

                background: Rectangle {
                    color: notifInlineReplyTextField.hovered ? Colours.highlight : Colours.shadow
                    border.color: parent.activeFocus ? Colours.power1 : (notifInlineReplyTextField.hovered ? Colours.snow0 : "transparent")
                    border.width: 2
                    radius: 8
                }

                SvgIcon {
                    id: notifInlineReplySend
                    iconName: "send"
                    size: root.iconSize / 2
                    colour: Colours.white
                    opacity: notifInlineReplyMouseArea.containsMouse ? 1 : 0.7

                    anchors {
                        right: parent.right
                        rightMargin: root.padding / 2
                        verticalCenter: parent.verticalCenter
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.Linear
                        }
                    }

                    MouseArea {
                        id: notifInlineReplyMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.modelData?.notification?.sendInlineReply(notifInlineReplyTextField.text)
                    }
                }
            }
        }
    }
}

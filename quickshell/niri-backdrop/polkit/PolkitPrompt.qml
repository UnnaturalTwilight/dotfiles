// PolkitPrompt.qml

import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.config
import qs.widgets

FloatingWindow {
    id: promptWindow
    title: "Polkit Agent"

    required property PolkitAgent agent
    property size windowSize: Qt.size(400, 400)

    minimumSize: windowSize
    maximumSize: windowSize
    surfaceFormat.opaque: false
    color: agent.isRegistered ? Colours.blurPane : Colours.power2
    visible: agent.isActive

    BackgroundEffect.blurRegion: Region {
        width: promptWindow.width
        height: promptWindow.height
    }

    onClosed: {
        agent.flow.cancelAuthenticationRequest();
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: 20
        columns: 4
        rowSpacing: 10
        columnSpacing: 10

        Text {
            id: promptText
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: promptWindow.windowSize.width - 40
            Layout.row: 0
            Layout.columnSpan: 4

            text: agent.flow?.message ?? "No active authentication"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 16
            font.family: Fonts.mono
            color: Colours.snow2
        }

        Text {
            id: detailsText
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: promptWindow.windowSize.width - 40
            Layout.row: 1
            Layout.columnSpan: 4

            text: agent.flow?.supplementaryMessage ?? "No details"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 14
            font.family: Fonts.mono
            color: Colours.text
            // visible: agent.flow?.supplementaryMessage != ""
        }

        Rectangle {
            id: animationBox
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.margins: 20
            Layout.row: 2
            Layout.columnSpan: 4

            color: Colours.highlight
            border.width: 3
            border.color: agent.flow?.failed ? Colours.aurora1 : Colours.snow0
            radius: 12

            Image {
                anchors.centerIn: parent
                source: Quickshell.iconPath(agent.flow?.iconName, true)
                width: parent.width * 0.6
                height: width
                sourceSize: Qt.size(width, height)
                visible: agent.flow?.iconName ?? false
            }

            SvgIcon {
                anchors.centerIn: parent
                iconName: "fingerprint"
                size: parent.width * 0.6
                colour: Colours.aurora4
                visible: !(agent.flow?.iconName)
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.Linear
                }
            }

            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.Linear
                }
            }
        }

        TextField {
            id: passwordField
            Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
            Layout.fillWidth: true
            Layout.row: 4
            Layout.columnSpan: 4
            focus: true

            echoMode: TextInput.Password
            passwordCharacter: "⏺"
            font.family: length ? Fonts.mono : Fonts.sans

            placeholderText: {
                var message = agent.flow?.inputPrompt.trim() ?? "Password";
                message.endsWith(":") ? message = message.slice(0, -1) : null;
                return message;
            }

            onAccepted: {
                agent.flow.submit(passwordField.text);
                passwordField.text = "";
            }

            Component.onCompleted: {
                passwordField.forceActiveFocus();
            }

            background: Rectangle {
                color: passwordField.hovered ? Colours.highlight : Colours.shadow
                border.color: parent.activeFocus ? Colours.power1 : Colours.snow0
                radius: 4
            }
        }

        Dropdown {
            id: userComboBox
            Layout.alignment: Qt.AlignRight
            Layout.column: 2
            Layout.row: 5
            Layout.preferredHeight: 30
            Layout.preferredWidth: 65

            model: agent.flow?.identities
            textRole: "displayName"
            leftPadding: 4

            onActivated: {
                const selectedIdentity = agent.flow?.identities[userComboBox.currentIndex];
                agent.flow.selectedIdentity = selectedIdentity;
            }
        }

        FlatButton {
            id: cancelButton
            text: "Cancel"

            Layout.alignment: Qt.AlignLeft
            Layout.column: 0
            Layout.row: 5
            Layout.preferredHeight: 30
            Layout.preferredWidth: 80

            onClicked: agent.flow.cancelAuthenticationRequest()
        }

        FlatButton {
            id: submitButton
            text: "Submit"

            Layout.alignment: Qt.AlignRight
            Layout.column: 3
            Layout.row: 5
            Layout.preferredHeight: 30
            Layout.preferredWidth: 80

            onClicked: {
                agent.flow.submit(passwordField.text);
                passwordField.text = "";
            }
        }
    }
}

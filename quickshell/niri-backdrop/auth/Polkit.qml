// Polkit.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Polkit
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs

Item {
    id: root

    PolkitAgent {
        id: agent

        onAuthenticationRequestStarted: {
            promptLoader.active = true;
        }
    }

    Connections {
        target: agent.flow

        function onAuthenticationSucceeded(): void {
            Qt.callLater(() => {
                promptLoader.active = false;
            });
        }

        function onAuthenticationRequestCancelled(): void {
            Qt.callLater(() => {
                promptLoader.active = false;
            });
        }
    }

    LazyLoader {
        id: promptLoader
        component: PolkitPromptWindow {}
        loading: false
    }

    component PolkitPromptWindow: FloatingWindow {
        id: promptWindow
        title: "Polkit Agent"

        property size windowSize: Qt.size(400, 400)

        minimumSize: windowSize
        maximumSize: windowSize
        surfaceFormat.opaque: false
        color: agent.isRegistered ? Qt.alpha(Colours.polar0, 0.8) : Colours.power2
        visible: agent.isActive

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
                color: Colours.text
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

                color: Colours.polar0
                border.width: 3
                border.color: agent.flow?.failed ? Colours.aurora1 : Colours.frost1
                radius: 12

                Image {
                    anchors.centerIn: parent
                    source: Quickshell.iconPath(agent.flow?.iconName, "dialog-password")
                    width: parent.width * 0.6
                    height: width
                    sourceSize: Qt.size(width, height)
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
            }

            ComboBox {
                id: userComboBox
                Layout.alignment: Qt.AlignRight
                Layout.column: 2
                Layout.row: 5
                Layout.preferredHeight: 30
                Layout.preferredWidth: 65
                // Layout.fillWidth: true

                model: agent.flow?.identities
                textRole: "displayName"
                onActivated: {
                    const selectedIdentity = agent.flow?.identities[userComboBox.currentIndex];
                    agent.flow.selectedIdentity = selectedIdentity;
                }
            }

            Button {
                id: cancelButton
                Layout.alignment: Qt.AlignLeft
                Layout.column: 0
                Layout.row: 5
                Layout.preferredHeight: 30

                text: "Cancel"
                onClicked: agent.flow.cancelAuthenticationRequest()
            }

            Button {
                id: submitButton
                Layout.alignment: Qt.AlignRight
                Layout.column: 3
                Layout.row: 5
                Layout.preferredHeight: 30

                text: "Submit"
                onClicked: {
                    agent.flow.submit(passwordField.text);
                    passwordField.text = "";
                }
            }
        }
    }
}

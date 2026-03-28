// Polkit.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Polkit
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs

Item {
    id: root

    PolkitAgent {
        id: agent
    }

    LazyLoader {
        id: promptLoader
        component: PolkitPromptWindow {}
        loading: true
    }

    component PolkitPromptWindow: FloatingWindow {
        id: promptWindow
        title: "Polkit Agent"

        property size windowSize: Qt.size(600, 400)

        minimumSize: windowSize
        maximumSize: windowSize

        visible: agent.isActive

        onClosed: {
            agent.flow.cancelAuthenticationRequest()
        }

        Rectangle {
            anchors.fill: parent
            color: agent.isRegistered ? Colours.darkGray : Colours.niri_urgent

            GridLayout {
                anchors.fill: parent
                columns: 4
                rowSpacing: 10
                columnSpacing: 10

                Text {
                    id: promptText
                    Layout.alignment: Qt.AlignHCenter
                    Layout.row: 0
                    Layout.topMargin: 20
                    Layout.columnSpan: 4

                    text: agent.flow?.message ?? "No active authentication"
                    font.pixelSize: 16
                    font.family: "JetBrainsMonoNF"
                    color: Colours.white
                }

                Text {
                    id: detailsText
                    Layout.alignment: Qt.AlignHCenter
                    Layout.row: 1
                    Layout.columnSpan: 4

                    text: agent.flow?.supplementaryMessage ?? "No details"
                    font.pixelSize: 14
                    font.family: "JetBrainsMonoNF"
                    color: Colours.white
                }

                Rectangle {
                    id: animationBox
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    Layout.margins: 20
                    Layout.row: 2
                    Layout.columnSpan: 4

                    color: Colours.kindaGray
                    border.width: 3
                    border.color: agent.flow?.failed ? Colours.niri_urgent : Colours.navy
                    radius: 8

                    IconImage {
                        anchors.centerIn: parent
                        source: Quickshell.iconPath(agent.flow?.iconName, "dialog-password")
                        width: 64
                        height: 64
                    }
                }

                Text {
                    id: instructionText
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                    Layout.fillWidth: true
                    Layout.row: 3
                    Layout.columnSpan: 4

                    text: {
                        var message = agent.flow?.inputPrompt.trim() ?? "Fallback prompt!";
                        message.endsWith(":") ? message = message.slice(0, -1) : null;
                        return message;
                    }
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 14
                    font.family: "JetBrainsMonoNF"
                    color: Colours.white
                }

                TextField {
                    id: passwordField
                    Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.bottomMargin: -20
                    Layout.row: 4
                    Layout.columnSpan: 3

                    echoMode: TextInput.Password
                    placeholderText: "Password"

                    onAccepted: {
                        agent.flow.submit(passwordField.text)
                        passwordField.text = ""
                    }
                }

                ComboBox {
                    id: userComboBox
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                    Layout.column: 3
                    Layout.row: 4
                    Layout.rightMargin: 20
                    Layout.bottomMargin: -20
                    Layout.preferredHeight: 30
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
                    Layout.margins: 20
                    Layout.preferredHeight: 30

                    text: "Cancel"
                    onClicked: agent.flow.cancelAuthenticationRequest()
                }

                Button {
                    id: submitButton
                    Layout.alignment: Qt.AlignRight
                    Layout.column: 3
                    Layout.row: 5
                    Layout.margins: 20
                    Layout.preferredHeight: 30

                    text: "Submit"
                    onClicked: {
                        agent.flow.submit(passwordField.text)
                        passwordField.text = ""
                    }
                }

            }
        }
    }
}

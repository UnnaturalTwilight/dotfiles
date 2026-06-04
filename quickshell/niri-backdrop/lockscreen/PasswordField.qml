// PasswordField.qml

import Quickshell.Services.Pam
import QtQuick
import QtQuick.Controls

import qs.config
import qs.widgets

Item {
    id: passwordField

    required property PamContext pam
    property bool fingerprint: false
    property string placeholderText: "Password"
    readonly property alias currentText: keyboardInput.text
    property int iconSize: 32

    signal submit(string password)

    Rectangle {
        id: pwFieldBackground
        anchors.fill: parent
        radius: 100
        border.width: 4
        color: Colours.highlight
        border.color: {
            if (passwordField.pam.messageIsError) {
                return Colours.aurora0;
            } else if (passwordField.pam.active) {
                return Colours.aurora4;
            } else {
                return "transparent";
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }
    }

    Rectangle {
        id: passwordIconArea
        width: parent.height
        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        color: "transparent"

        SvgIcon {
            id: passwordIcon
            iconName: passwordField.fingerprint ? "fingerprint" : "password"
            size: passwordField.iconSize
            anchors.centerIn: parent
            opacity: (passwordField.pam.responseRequired || !passwordField.pam.active) ? 1 : 0.5
        }
    }

    Text {
        id: displayText
        text: {
            if (passwordField.currentText.length === 0) {
                return passwordField.placeholderText;
            } else {
                return "⏺".repeat(passwordField.currentText.length);
            }
        }
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: 200
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Colours.white
        font.pixelSize: 24
        font.family: Fonts.mono
        font.italic: passwordField.currentText.length === 0
    }

    Rectangle {
        id: sendButtonArea
        width: height
        height: parent.height - 8
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        color: sendButtonMouseArea.containsMouse ? Colours.highlight : "transparent"

        topRightRadius: 100
        bottomRightRadius: 100

        MouseArea {
            id: sendButtonMouseArea
            anchors.fill: parent
            hoverEnabled: passwordField.pam.responseRequired
            onClicked: {
                passwordField.submit(passwordField.currentText);
            }
        }

        SvgIcon {
            id: sendButton
            iconName: "arrow-right"
            size: passwordField.iconSize
            anchors.centerIn: parent
            opacity: passwordField.pam.responseRequired ? 1 : 0.5
        }
    }

    TextField {
        id: keyboardInput
        width: 0
        height: 0
        visible: false
        enabled: true
        echoMode: TextInput.Password
        focus: true

        onDisplayTextChanged: {
            if (!passwordField.pam.active) {
                passwordField.pam.start();
            }
        }

        onCursorPositionChanged: {
            // cursor is invisible so force it to the end to avoid confusion
            if (cursorPosition !== text.length) {
                cursorPosition = text.length;
            }
        }

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                keyboardInput.text = "";
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                passwordField.submit(passwordField.currentText);
                event.accepted = true;
            }
        }

        Component.onCompleted: forceActiveFocus()
    }
}

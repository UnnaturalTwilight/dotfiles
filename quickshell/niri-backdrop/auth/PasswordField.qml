// PasswordField.qml
import Quickshell
import Quickshell.Services.Pam
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls

import qs

Item {
    id: passwordField

    required property PamContext pam
    property bool spinner: false
    property string placeholderText: "󰌾 Logged in as " + Quickshell.env("USER")
    property string currentText: ""

    anchors.centerIn: parent
    anchors.verticalCenterOffset: 50
    width: 300

    function tryUnlock() {
        if (!pam.active) {
            pam.start();
        }
        if (pam.responseRequired) {
            pam.respond(currentText);
        }
        spinner = true;
    }

    ClippingRectangle {
        id: pwFieldBackground
        implicitWidth: 300
        implicitHeight: 60
        radius: 100
        border.width: 4
        color: Colours.white
        border.color: {
            if (passwordField.spinner) {
                return Colours.pinkish;
            } else if (passwordField.pam.messageIsError) {
                return Colours.niri_urgent;
            } else if (passwordField.pam.active) {
                return Colours.darkViolet;
            } else {
                return Colours.navy;
            }
        }

        Text {
            id: placeholder
            text: passwordField.placeholderText
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Colours.darkGray
            font.pixelSize: 20
            font.family: "Noto Sans"
            visible: !passwordField.spinner && passwordField.currentText.length === 0
        }

        Text {
            id: asterisks
            text: "⏺".repeat(passwordField.currentText.length)
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Colours.black
            font.pixelSize: 28
            font.family: "JetBrainsMonoNFM"
            visible: passwordField.currentText.length > 0
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
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

        // Bidirectional sync — avoids a declarative binding which breaks on input
        onTextChanged: {
            if (passwordField.currentText !== text)
                passwordField.currentText = text;
        }

        Connections {
            target: passwordField
            function onCurrentTextChanged() {
                if (keyboardInput.text !== passwordField.currentText) {
                    keyboardInput.text = passwordField.currentText;
                }
            }
        }

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
                passwordField.currentText = "";
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                passwordField.tryUnlock();
                event.accepted = true;
            }
        }

        Component.onCompleted: forceActiveFocus()
    }
}

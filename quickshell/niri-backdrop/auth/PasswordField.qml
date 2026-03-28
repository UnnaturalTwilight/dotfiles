// PasswordField.qml
import Quickshell
import Quickshell.Services.Pam
import QtQuick
import QtQuick.Controls

import qs

TextField {
    id: passwordField

    required property PamContext pam
    property bool spinner: false

    anchors.centerIn: parent
    anchors.verticalCenterOffset: 50
    width: 300
    placeholderText: "󰌾 Logged in as " + Quickshell.env("USER")
    placeholderTextColor: Colours.darkGray
    font.family: "JetBrainsMonoNFM"
    font.pixelSize: 20
    color: Colours.black
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    echoMode: TextInput.Password
    passwordCharacter: "⏺"
    focus: true

    background: Rectangle {
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

        Behavior on border.color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.Linear
            }
        }
    }

    onDisplayTextChanged: {
        if (!pam.active) {
            pam.start();
        }
    }

    onAccepted: {
        if (!pam.active) {
            pam.start();
        }
        if (pam.responseRequired) {
            pam.respond(passwordField.text);
        }
        passwordField.spinner = true;
    }
}

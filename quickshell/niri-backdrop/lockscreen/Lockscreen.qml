// Lockscreen.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pam
import QtQuick

import qs.config
import qs.backdrop
import qs.widgets

Item {
    id: lockScreen
    anchors.fill: parent

    required property ShellScreen screen
    required property PamContext pam
    property string message: ""
    property bool fingerprint: false

    Connections {
        target: lockScreen.pam

        function onPamMessage() {
            const msg = lockScreen.pam.message.trim();

            if (lockScreen.pam.messageIsError) {
                msg.endsWith(":") ? lockScreen.message = msg.slice(0, -1) : lockScreen.message = msg;
            } else {
                if (msg.includes("finger")) {
                    lockScreen.fingerprint = true;
                } else {
                    lockScreen.fingerprint = false;
                }
            }
        }
    }

    function tryUnlock(response: string) {
        if (!pam.active) {
            pam.start();
        }
        if (pam.responseRequired) {
            pam.respond(response);
        }
    }

    MouseArea {
        id: bgMouseArea
        // onClicked: lock.locked = false
        onClicked: {
            lockScreen.pam.start();
        }

        anchors.fill: parent
    }

    Image {
        id: background
        source: Quickshell.env("XDG_CONFIG_HOME") + "/assets/lockscreen" // auto detect extension
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        id: avatar
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -150
        width: 300
        height: 300
        color: Colours.highlight
        radius: 150

        Image {
            anchors.fill: parent
            source: Quickshell.env("XDG_CONFIG_HOME") + "/profilepic" // auto detect extension
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectFit

            mipmap: true
            antialiasing: true
            smooth: true
        }
    }

    Text {
        id: usernameText
        text: Quickshell.env("USER")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: avatar.bottom
        anchors.margins: 10
        font.pixelSize: 32
        font.family: Fonts.mono
        font.weight: 700
        color: Colours.white
    }

    PasswordField {
        id: passwordField
        pam: lockScreen.pam
        fingerprint: lockScreen.fingerprint

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: usernameText.bottom
        anchors.topMargin: 10
        width: 320
        height: 60

        onSubmit: text => {
            lockScreen.tryUnlock(text);
        }
    }

    Text {
        id: messageText
        text: lockScreen.message
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: passwordField.bottom
        anchors.topMargin: 10
        font.pixelSize: 16
        font.family: Fonts.sans
        color: Colours.white
    }

    Clock {
        screen: lockScreen.screen
    }

    Symbols {
        screen: lockScreen.screen
    }

    //MediaBar {
    //    anchors.horizontalCenter: parent.horizontalCenter
    //    anchors.bottom: parent.bottom
    //    anchors.bottomMargin: 50
    //}
}

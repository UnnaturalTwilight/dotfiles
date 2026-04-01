// Lockscreen.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pam
import QtQuick

import qs
import qs.backdrop

Item {
    id: lockScreen
    anchors.fill: parent

    required property ShellScreen screen
    required property var lockData
    required property PamContext pam
    property string message: ""
    property bool spinner: false
    property bool gracePeriodActive: false
    property bool fingerprint: false

    Component.onCompleted: {
        graceTimer.restart();
        lockScreen.gracePeriodActive = lockData.gracePeriod;
        lockScreen.spinner = false;
    }

    Connections {
        target: lockScreen.pam

        function onCompleted() {
            lockScreen.spinner = false;
            lockScreen.message = "";
        }

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
        if (gracePeriodActive && response === "") {
            lockScreen.lockData.unlock();
            return;
        }
        if (!pam.active) {
            pam.start();
        }
        if (pam.responseRequired) {
            pam.respond(response);
        }
        gracePeriodActive = false;
        spinner = true;
    }

    MouseArea {
        id: bgMouseArea
        // onClicked: lock.locked = false
        onClicked: {
            if (lockScreen.gracePeriodActive) {
                lockScreen.lockData.unlock();
            } else {
                lockScreen.pam.start();
            }
        }

        anchors.fill: parent
    }

    Timer {
        id: graceTimer
        interval: lockScreen.lockData.gracePeriodMs
        running: true

        onTriggered: {
            // Disable grace
            lockScreen.gracePeriodActive = false;
        }
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
        color: Qt.alpha(Colours.white, 0.15)
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
        font.family: "JetBrainsMonoNF"
        font.weight: 700
        color: Colours.white
    }

    PasswordField {
        id: passwordField
        pam: lockScreen.pam
        spinner: lockScreen.spinner
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
        font.family: "Noto Sans"
        color: Colours.white
    }

    Clock {
        screen: lockScreen.screen
    }

    Symbols {
        screen: lockScreen.screen
    }
}

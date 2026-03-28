// Lockscreen.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pam
import QtQuick

import qs
import qs.utils
import qs.backdrop

Item {
    id: lockScreen
    anchors.fill: parent

    required property ShellScreen screen
    required property var lockData
    property bool spinner: false
    property bool gracePeriodActive: true

    Component.onCompleted: {
        graceTimer.restart();
        lockScreen.gracePeriodActive = true;
        lockScreen.spinner = false;
    }

    MouseArea {
        id: bgMouseArea
        // onClicked: lock.locked = false
        onClicked: {
            if (lockScreen.gracePeriodActive) {
                lockScreen.lockData.unlock();
            } else {
                pam.start();
            }
        }

        anchors.fill: parent
    }

    PamContext {
        id: pam

        // config: "login"
        active: false

        onCompleted: result => {
            console.log("PAM authentication completed with result: " + result.toString());
            passwordField.currentText = "";
            lockScreen.spinner = false;
            if (result === PamResult.Success) {
                lockScreen.lockData.unlock();
            }
        }
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

    Text {
        text: pam.message
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 100
        font.pixelSize: 24
        color: Colours.navy
        font.family: "JetBrainsMonoNFM"
    }

    Image {
        source: Quickshell.env("XDG_CONFIG_HOME") + "/assets/lockscreen" // auto detect extension
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }

    Image {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -175
        width: 300
        height: 300
        source: Quickshell.env("XDG_CONFIG_HOME") + "/profilepic" // auto detect extension
        sourceSize.width: 1250
        sourceSize.height: 1250
        fillMode: Image.PreserveAspectFit
    }

    PasswordField {
        id: passwordField
        pam: pam
    }

    Clock {
        screen: lockScreen.screen
    }

    Symbols {
        screen: lockScreen.screen
    }
}

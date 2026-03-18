// Lockscreen.qml
// Parts of this is ripped from my SDDM theme

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import QtQuick.Layouts

import qs

Scope {
    id: sessionLock

    IpcHandler {
        target: "lock"

        function lock(): void {
            unlockTimer.running = true;
            lock.locked = true;
        }
    }

    WlSessionLock {
        id: lock

        locked: false

        WlSessionLockSurface {
            id: lockscreen
            LockScreen {}
        }
    }

    // Auto unlock so that I don't get stuck when testing
    Timer {
        id: unlockTimer
        interval: 10000
        running: false
        repeat: false
        onTriggered: lock.locked = false
    }

    component LockScreen: Item {
        id: lockScreen
        anchors.fill: parent

        // This is really just a placeholder, but it works for testing

        MouseArea {
            // onClicked: lock.locked = false
            onClicked: pam.active = true
            anchors.fill: parent
        }

        PamContext {
            id: pam

            // config: "hyprlock"

            active: false

            onCompleted: {
                console.log("PAM authentication completed with result: " + result.toString());
                if (result === PamResult.Success) {
                    lock.locked = false;
                }
            }
        }

        Text {
            text: pam.message
            anchors.centerIn: parent
            font.pixelSize: 24
            color: Colours.pinkish
        }

        Image {
            source: Quickshell.env("XDG_CONFIG_HOME") + "/assets/lockscreen" // auto detect extension
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
        }

        Image {
            anchors.centerIn: parent
            width: 300
            height: 300
            source: Quickshell.env("XDG_CONFIG_HOME") + "/profilepic" // auto detect extension
            sourceSize.width: 1250
            sourceSize.height: 1250
            fillMode: Image.PreserveAspectFit
        }
    }
}

// DebugPane.qml

import Quickshell
import QtQuick

import qs.config
import qs.services
import qs.widgets

Rectangle {
    id: debugPane
    radius: 12
    color: Qt.alpha(Colours.snow0, 0.6)
    border.color: Colours.snow0
    border.width: 2

    Text {
        id: debugText
        anchors.fill: parent
        anchors.margins: 10
        text: JSON.stringify("DEBUG", null, 1)
        font.family: Fonts.mono
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        width: 400
    }

    FlatButton {
        text: "Reload"
        anchors.margins: 10
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        onClicked: {
            Quickshell.reload(false);
        }

        onPressAndHold: {
            Quickshell.reload(true);
        }
    }

    FlatButton {
        text: "Test Notifications"
        anchors.margins: 10
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onClicked: {
            const cmd = [Quickshell.env("HOME") + "/dotfiles/scripts/notif-test.sh"]
            console.log("Running notif-test.sh")
            Quickshell.execDetached(cmd)
            System.panelTab = 0;
        }
    }

}

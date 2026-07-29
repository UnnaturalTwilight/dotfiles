// OSD.qml
// Based on: https://git.outfoxxed.me/quickshell/quickshell-examples/src/branch/master/volume-osd/shell.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.config
import qs.widgets

Item {
    id: root

    required property real value
    required property string icon
    property int popupWidth: 400
    property int popupHeight: 50

    function showOsd() {
        root.shouldShowOsd = true;
        hideTimer.restart();
    }

    property bool shouldShowOsd: false

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.shouldShowOsd = false
    }

    states: [
        State {
            name: "hidden"
            when: !root.shouldShowOsd
            PropertyChanges {
                background.y: 100
                background.opacity: 0
            }
        },
        State {
            name: "shown"
            when: root.shouldShowOsd
            PropertyChanges {
                background.y: 0
                background.opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            to: "hidden"
            NumberAnimation {
                properties: "y,opacity"
                easing.type: Easing.InQuad
                duration: 250
            }
        },
        Transition {
            to: "shown"
            NumberAnimation {
                properties: "y,opacity"
                easing.type: Easing.OutQuad
                duration: 250
            }
        }
    ]

    Rectangle {
        id: background
        opacity: 0

        implicitWidth: root.popupWidth
        implicitHeight: root.popupHeight
        radius: height / 2
        color: Colours.blurPane
        border.color: Colours.frost0
        border.width: 2

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 15
                rightMargin: 15
            }

            Text {
                text: root.icon
                font.pixelSize: 30
                font.family: Fonts.nerdMono
                color: Colours.text
                // Layout.preferredWidth: percentageText.width
            }

            PercentBar {
                Layout.fillWidth: true
                value: root.value
                implicitHeight: 12
                bgColor: Colours.polar1
                fgColor: Colours.snow0
            }

            Text {
                id: percentageText
                text: (Math.round(root.value * 100) + "%").padStart(5, " ")
                color: Colours.text
                font.pixelSize: 16
                font.family: Fonts.mono
            }
        }
    }
}

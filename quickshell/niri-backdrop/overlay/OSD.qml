// OSD.qml
// Based on: https://git.outfoxxed.me/quickshell/quickshell-examples/src/branch/master/volume-osd/shell.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs
import qs.widgets

Scope {
    id: root

    required property ShellScreen screen
    required property real value
    required property string icon
    property bool suppress: false

    function showOsd() {
        if (!root.suppress) {
            root.shouldShowOsd = true;
            root.osdVisible = true;
            hideTimer.restart();
        }
    }

    property bool shouldShowOsd: false
    property bool osdVisible: false

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    // The OSD window will be created and destroyed based on shouldShowOsd.
    // PanelWindow.visible could be set instead of using a loader, but using
    // a loader will reduce the memory overhead when the window isn't open.
    LazyLoader {
        active: root.osdVisible

        PanelWindow {
            id: osdWindow
            // set the popup to be on my laptop screen
            screen: root.screen

            anchors.bottom: true
            margins.bottom: 50
            exclusiveZone: 0

            implicitWidth: 400
            implicitHeight: 50
            color: "transparent"

            // An empty click mask prevents the window from blocking mouse events.
            mask: Region {}

            Rectangle {
                id: background
                opacity: 0

                anchors.fill: parent
                radius: height / 2
                color: Colours.shadow

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
                        color: Colours.gray
                        // Layout.preferredWidth: percentageText.width
                    }

                    PercentBar {
                        Layout.fillWidth: true
                        value: root.value
                        implicitHeight: 12
                        bgColor: Colours.polar1
                        fgColor: Colours.snow5
                    }

                    Text {
                        id: percentageText
                        text: (Math.round(root.value * 100) + "%").padStart(5, " ")
                        color: Colours.text
                        font.pixelSize: 16
                        font.family: Fonts.mono
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                        onFinished: root.osdVisible = root.shouldShowOsd
                    }
                }

                Component.onCompleted: {
                    background.opacity = 1;
                }

                Connections {
                    target: root

                    function onShouldShowOsdChanged() {
                        background.opacity = root.shouldShowOsd ? 1 : 0;
                    }
                }
            }
        }
    }
}

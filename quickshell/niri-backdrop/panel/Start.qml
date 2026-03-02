// Start.qml
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import qs
import qs.utils

PanelWindow {
    id: startPanel
    required property var modelData
    screen: modelData
    visible: modelData.name === "eDP-1"

    IpcHandler {
        target: "start"

        function toggle(): void {
            startPanel.visible = !startPanel.visible;
        }
        function show(): void {
            startPanel.visible = true;
        }
        function hide(): void {
            startPanel.visible = false;
        }
    }

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "overlay-qt-start"
    color: "transparent"
    surfaceFormat.opaque: false

    anchors {
        top: true
        right: true
        left: false
        bottom: true
    }

    margins {
        top: 30
        right: 30
        left: 0
        bottom: 30
    }

    implicitWidth: startBox.implicitWidth
    implicitHeight: startBox.implicitHeight
    Rectangle {
        id: startBox
        anchors.fill: parent
        color: Colours.black
        opacity: 0.5
        radius: 12
        implicitWidth: 400
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            RowLayout {
                spacing: 30
                Layout.alignment: Qt.AlignCenter

                Text {
                    text: ""
                    color: Colours.white
                    font.pixelSize: 48
                    font.family: "JetBrainsMonoNFM"
                }

                Text {
                    text: ""
                    color: Colours.white
                    font.pixelSize: 48
                    font.family: "JetBrainsMonoNFM"
                }

                Text {
                    text: "󰤄"
                    color: Colours.white
                    font.pixelSize: 48
                    font.family: "JetBrainsMonoNFM"
                }

                Text {
                    text: ""
                    color: Colours.white
                    font.pixelSize: 48
                    font.family: "JetBrainsMonoNFM"
                }

                Text {
                    text: ""
                    color: Colours.white
                    font.pixelSize: 48
                    font.family: "JetBrainsMonoNFM"
                }
            }
        }
    }

    component InfoTile: Rectangle {}
}

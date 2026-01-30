// Symbols.qml
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bgSysPanel
    required property var modelData
    screen: modelData
    // I would prefer not to have an invisible window on other screens, but I can't figure out Loaders right now.
    visible: modelData.name === "eDP-1"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "backdrop-qt-symbols"
    color: "transparent"
    surfaceFormat.opaque: false

    anchors {
        top: false
        right: true
        left: false
        bottom: true
    }

    margins {
        top: 0
        right: 50
        left: 0
        bottom: 40
    }

    implicitWidth: sysLayout.implicitWidth
    implicitHeight: sysLayout.implicitHeight
    GridLayout {
        id: sysLayout
        rows: 2
        columnSpacing: 20
        rowSpacing: -5
        flow: GridLayout.TopToBottom

        Text {
            id: audioIcon
            Layout.alignment: Qt.AlignCenter
            text: Audio.icon
            color: "#b0b4bc"
            opacity: Audio.muted ? 0.5 : 1.0
            font.family: "JetBrainsMonoNFM"
            font.pixelSize: Audio.styles[0]
            Layout.bottomMargin: Audio.styles[1]
        }

        Rectangle {
            // Stretches to fill all left-over space
            Layout.fillWidth: true
            implicitHeight: 10
            implicitWidth: 60
            radius: 20
            color: "#4e4e4e"

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                implicitWidth: parent.width * Audio.volume
                radius: parent.radius
                color: "#D35D6E"
                opacity: Audio.muted ? 0.5 : 1.0
            }
        }

        Text {
            id: batteryIcon
            Layout.alignment: Qt.AlignCenter
            text: Battery.icon
            color: "#b0b4bc"
            font.family: "JetBrainsMonoNFM"
            font.pixelSize: 88
            Layout.bottomMargin: -8
        }

        Rectangle {
            // Stretches to fill all left-over space
            Layout.fillWidth: true

            implicitHeight: 10
            implicitWidth: 60
            radius: 20
            color: "#4e4e4e"

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }

                implicitWidth: parent.width * Battery.value
                radius: parent.radius
                color: "#D35D6E"
            }
        }
    }
}

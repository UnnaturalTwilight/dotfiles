// Clock.qml
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bgClockPanel
    required property var modelData
    screen: modelData
    // I would prefer not to have an invisible window on other screens, but I can't figure out Loaders right now.
    // visible: modelData.name === "eDP-1"

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "backdrop-qt-clock"
    color: "transparent"
    surfaceFormat.opaque: false

    anchors {
        top: true
        right: true
        left: false
        bottom: false
    }

    margins {
        top: 30
        right: 50
        left: 0
        bottom: 0
    }

    implicitWidth: clockLayout.implicitWidth
    implicitHeight: clockLayout.implicitHeight
    ColumnLayout {
        id: clockLayout
        spacing: -24

        Text {
            id: timeText
            Layout.alignment: Qt.AlignCenter
            text: Time.time
            color: Colours.kindaGray
            font.pixelSize: 128
            font.family: "JetBrainsMonoNFM"
        }

        Text {
            id: dateText
            Layout.alignment: Qt.AlignCenter
            text: Time.date
            color: Colours.kindaGray
            font.pixelSize: 24
            font.family: "Noto Sans"
        }
    }
}

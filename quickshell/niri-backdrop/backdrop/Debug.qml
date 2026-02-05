// Debug.qml
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs
import qs.utils
import qs.utils.niri

PanelWindow {
    id: bgDEBUGPanel
    required property var modelData
    screen: modelData

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "backdrop-qt-debug"
    color: Qt.alpha("red", 0.5)
    surfaceFormat.opaque: false

    anchors {
        top: true
        right: false
        left: true
        bottom: false
    }

    margins {
        top: 30
        right: 0
        left: 50
        bottom: 0
    }

    implicitWidth: Math.max(debugLayout.implicitWidth, debugLayout2.implicitWidth)
    implicitHeight: debugLayout.implicitHeight + debugLayout2.implicitHeight + 40
    Grid {
        id: debugLayout
        spacing: -24
        rows: children.length

        Repeater {
            id: repeater

            model: ScriptModel {
                // You can filter the workspaces based on the `output` variable so
                // only the workspaces from the current monitor are visible.
                values: [...Niri.workspaces.filter(w => w.output === bgDEBUGPanel.screen?.name)]
            }

            DebugItem {
                Layout.alignment: Qt.AlignCenter
            }
        }
    }

    // Text {
    //         id: debugLayout
    //         Layout.alignment: Qt.AlignTop
    //         text: JSON.stringify(Niri.workspaces) + "\n"
    //         color: Colours.kindaGray
    //         font.pixelSize: 16
    //         font.family: "JetBrainsMonoNFM"
    //         wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    //         width: 1500
    //     }

    Text {
            id: debugLayout2
            Layout.alignment: Qt.AlignBottom
            text: [...Niri.windows].sort((a, b) => a.workspaceId - b.workspaceId).map(w => JSON.stringify([w.windowId,[w.workspaceId, w.positionInWorkspace]])).join("\n") + "\n"
            color: Colours.kindaGray
            font.pixelSize: 16
            font.family: "JetBrainsMonoNFM"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: 1500
            y: debugLayout.implicitHeight + 20
        }

    component DebugItem: Rectangle {
        id: debugRect
        required property var modelData
        radius: 8
        color: "transparent"
        implicitWidth: debugText.implicitWidth + 20
        implicitHeight: debugText.implicitHeight + 20

        Text {
            id: debugText
            Layout.alignment: Qt.AlignCenter
            text: debugRect.modelData.workspaceId + 
            " : " + JSON.stringify([...debugRect.modelData.windows].map(w => [w.windowId, w.positionInWorkspace])) + "\n"
            color: Colours.kindaGray
            font.pixelSize: 16
            font.family: "JetBrainsMonoNFM"
            wrapMode: Text.WrapAnywhere
            width: 1000
        }

    }
}

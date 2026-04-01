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
        spacing: 5
        rows: children.length
        padding: 10

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

        Text {
            id: debugLayout2
            Layout.alignment: Qt.AlignBottom
            // qmlformat off
            text: "Focused Window ID: " + (Niri?.focusedWindow?.windowId) + "\n" +
                "Focused workspace ID: " + (Niri?.focusedWorkspace?.workspaceId) + "\n" +
                [...Niri.windows].sort((a, b) => a.workspaceId - b.workspaceId)
                    .map(w => JSON.stringify([
                        w.windowId,{"ID": w.workspaceId, "pos": w.positionInWorkspace, "urgent": w.isUrgent, "floating": w.isFloating}
                    ])).join("\n") + "\n" + "\n" + bgDEBUGPanel.modelData.name
            // qmlformat on
            color: Colours.gray
            font.pixelSize: 16
            font.family: "JetBrainsMonoNFM"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        /* Text {
            id: debugOutputs
            Layout.alignment: Qt.AlignBottom
            // qmlformat off
            text: "Outputs: \n" + [...Niri.outputs].map(o => JSON.stringify([
                o.name, {"modes": o.modes.length, "currentMode": o.currentMode}
            ])).join("\n") + "\nFocused Output: " + (Niri.focusedOutput ? Niri.focusedOutput.name : "None")
            // qmlformat on
            color: Colours.gray
            font.pixelSize: 16
            font.family: "JetBrainsMonoNFM"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        } */
    }

    component DebugItem: Rectangle {
        id: debugRect
        required property var modelData
        radius: 8
        color: "transparent"
        implicitWidth: debugText.implicitWidth + 20
        implicitHeight: debugText.implicitHeight

        Text {
            id: debugText
            Layout.alignment: Qt.AlignCenter
            // qmlformat off
            text: debugRect.modelData.workspaceId + " : " +
                JSON.stringify([...debugRect.modelData.windows].map(w => [
                    w.windowId, {"wsID": w.workspaceId, "pos": w.positionInWorkspace, "urgent": w.isUrgent, "floating": w.isFloating}
                ]))
            // qmlformat on
            color: Colours.gray
            font.pixelSize: 16
            font.family: "JetBrainsMonoNFM"
            wrapMode: Text.WrapAnywhere
            width: 1000
        }
    }
}

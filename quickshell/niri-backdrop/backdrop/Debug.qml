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
    color: Qt.alpha("red", 0.3)
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

    implicitWidth: debugLayout.implicitWidth
    implicitHeight: debugLayout.implicitHeight
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
            " : " + [...debugRect.modelData?.windows].map(w => w.windowId).join(" ") +
            " : " + [...debugRect.modelData?.windows].map(w => w.title).join(" ") +
            " : " + [...debugRect.modelData?.windows].map(w => w.appId).join(" ") +
            " : " + [...debugRect.modelData?.windows].map(w => w.pid).join(" ") +
            " : " + [...debugRect.modelData?.windows].map(w => w.workspaceId).join(" ") +
            " : " + [...debugRect.modelData?.windows].map(w => w.isFocused).join(" ") +
            " : " + [...debugRect.modelData?.windows].map(w => w.isFloating).join(" ") +
            " : " + [...debugRect.modelData?.windows].map(w => w.isUrgent).join(" ");
            color: Colours.kindaGray
            font.pixelSize: 16
            font.family: "JetBrainsMonoNFM"
        }

    }
}

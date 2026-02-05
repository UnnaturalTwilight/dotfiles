// Workspaces.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qs
import qs.utils
import qs.utils.niri

PanelWindow {
    id: bgWorkspacesPanel
    required property var modelData
    screen: modelData

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "backdrop-qt-workspaces"
    color: "transparent"
    surfaceFormat.opaque: false

    anchors {
        top: false
        right: false
        left: true
        bottom: true
    }

    margins {
        top: 0
        right: 0
        left: 40
        bottom: 80
    }

    implicitWidth: wrapper.implicitWidth + 32
    implicitHeight: wrapper.implicitHeight + 32

    RectangularShadow {
        id: shadowBox
        anchors.fill: wrapper
        offset.x: 0
        offset.y: 0
        radius: wrapper.radius
        blur: 8
        spread: 12
        color: Qt.alpha(Colours.black, 0.3)
    }

    Rectangle {
        id: wrapper
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter

        implicitWidth: workspaceLayout.implicitWidth + 8
        implicitHeight: workspaceLayout.implicitHeight + 8
        radius: Math.min(width, height) / 2

        color: Qt.alpha(Colours.navy, 0.5)

        Grid {
            id: workspaceLayout
            anchors.centerIn: parent
            rows: 1
            columns: children.length
            columnSpacing: 4
            rightPadding: -4

            // add: Transition {
            // 	M3NumberAnim {
            // 		data: Anims.current.spatial.fast
            // 		properties: "scale"
            // 		from: 0
            // 		to: 1
            // 	}
            // }

            Repeater {
                id: repeater

                model: ScriptModel {
                    // You can filter the workspaces based on the `output` variable so
                    // only the workspaces from the current monitor are visible.
                    values: [...Niri.workspaces.filter(w => w.output === bgWorkspacesPanel.screen?.name)]
                }

                WorkspaceItem {
                    Layout.alignment: Qt.AlignCenter
                }
            }
        }
    }

    component WorkspaceItem: Rectangle {
        id: workspaceItem
        required property NiriWorkspace modelData
        readonly property bool active: modelData.isFocused
        readonly property bool empty: modelData.windows.length === 0

        radius: Math.min(width, height) / 2

        implicitWidth: Math.max(windowLayout.implicitWidth + 8, 30)
        implicitHeight: 30

        color: active ? Colours.darkGray : !empty ? Colours.navy : "transparent"
        // opacity: 0.8

        Behavior on color {
            ColorAnimation {
                duration: 50
                easing.type: Easing.Linear
            }
        }

        Grid {
            id: windowLayout
            anchors.centerIn: parent
            columns: children.length
            columnSpacing: 4
            rightPadding: -4

            Repeater {
                id: windowRepeater

                model: ScriptModel {
                    values: workspaceItem.modelData.windows.length > 0 ? [...workspaceItem.modelData.windows].sort((a, b) => a.positionInWorkspace - b.positionInWorkspace) : [Niri.emptyWindow]
                }

                WindowItem {
                    Layout.alignment: Qt.AlignCenter
                }
            }

            // Debug
            // rows: 2
            // rowSpacing: 60
        }

        // Text {
        //     id: debugText
        //     anchors.centerIn: parent
        //     text: modelData.workspaceId + ":" + modelData.windows.length || "?"
        //     color: "white"
        //     font.family: "JetBrainsMonoNFM"
        //     font.pixelSize: 14
        // }
    }

    component WindowItem: Rectangle {
        id: windowItem
        required property NiriWindow modelData
        readonly property bool empty: (modelData?.windowId ?? -1) <= 0
        readonly property bool active: Niri?.focusedWorkspace?.workspaceId === modelData.workspaceId
        readonly property bool focused: Niri?.focusedWindow?.windowId === modelData.windowId && !Niri?.overviewOpened
        readonly property bool urgent: modelData?.isUrgent
        readonly property bool floating: modelData?.isFloating

        radius: Math.min(width, height) / 2

        implicitWidth: 20
        implicitHeight: 20

        color: empty ? Qt.alpha(Colours.navy, 0.6) : 
            active && focused ? Colours.pinkish : 
            active && urgent ? Colours.niri_urgent : 
            active && floating ? Colours.niri_float : 
            urgent ? Qt.alpha(Colours.niri_urgent, 0.8) : 
            floating ? Qt.alpha(Colours.niri_float, 0.6) : 
            active ? Qt.alpha(Colours.pinkish, 0.6) : 
            Qt.alpha(Colours.kindaGray, 0.6)
        // opacity: 0.8

        Behavior on color {
            ColorAnimation {
                duration: 50
                easing.type: Easing.Linear
            }
        }

        // implicitWidth: debugText.implicitWidth + 10
        // Text {
        //     id: debugText
        //     anchors.centerIn: parent
        //     text: windowItem.modelData.windowId || "?"
        //     color: "white"
        //     font.family: "JetBrainsMonoNFM"
        //     font.pixelSize: 14
        // }
    }
}

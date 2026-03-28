// Workspaces.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qs
import qs.utils.niri

Item {
    id: bgWorkspaces
    required property var screen

    implicitWidth: wrapper.implicitWidth + 32
    implicitHeight: wrapper.implicitHeight + 32

    x: 40
    y: screen?.height - (40 + implicitHeight)

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

        GridLayout {
            id: workspaceLayout
            anchors.centerIn: parent
            rows: 1
            columns: children.length
            columnSpacing: 4

            Repeater {
                id: repeater

                model: ScriptModel {
                    // You can filter the workspaces based on the `output` variable so
                    // only the workspaces from the current monitor are visible.
                    values: [...Niri.workspaces.filter(w => w.output === bgWorkspaces.screen?.name)]
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
        readonly property bool active: modelData?.isFocused ?? false
        readonly property bool empty: modelData?.windows.length === 0

        radius: Math.min(width, height) / 2

        implicitWidth: Math.max(windowLayout.implicitWidth + 8, 30)
        implicitHeight: 30

        color: active ? Colours.darkGray : !empty ? Colours.navy : "transparent"
        // opacity: 0.8

        Behavior on color {
            ColorAnimation {
                duration: 100
                easing.type: Easing.Linear
            }
        }

        GridLayout {
            id: windowLayout
            anchors.centerIn: parent
            columns: children.length
            columnSpacing: 4

            Repeater {
                id: windowRepeater

                model: ScriptModel {
                    values: {
                        if (!workspaceItem.empty) {
                            return [...workspaceItem.modelData.windows].sort(bgWorkspaces.windowSortingFunction);
                        } else {
                            return [null];
                        }
                    }
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

    function windowSortingFunction(a, b) {
        // Sorts tiled windows left-to-right and then top-to-bottom within their column
        // Floating windows end up first due to having -1 for both indices
        const aXindex = a.layout.tileIndexInScrollingLayout;
        const bXindex = b.layout.tileIndexInScrollingLayout;
        if (aXindex === bXindex) {
            const aYindex = a.layout.columnIndexInScrollingLayout;
            const bYindex = b.layout.columnIndexInScrollingLayout;
            return aYindex - bYindex;
        }
        return aXindex - bXindex;
    }

    component WindowItem: Rectangle {
        id: windowItem
        required property NiriWindow modelData
        readonly property bool empty: modelData === null
        readonly property bool active: Niri.focusedWorkspace?.workspaceId === modelData?.workspaceId
        readonly property bool focused: Niri.focusedWindow?.windowId === modelData?.windowId && !Niri?.overviewOpened
        readonly property bool urgent: modelData?.isUrgent ?? false
        readonly property bool floating: modelData?.isFloating ?? false

        radius: Math.min(width, height) / 2

        implicitWidth: 20
        implicitHeight: 20

        // qmlformat off
        color: empty ? Qt.alpha(Colours.navy, 0.6) :
            active && floating && focused ? Colours.niri_float :
            active && focused ? Colours.pinkish :
            active && urgent ? Colours.niri_urgent :
            active && floating ? Qt.alpha(Colours.niri_float, 0.6) :
            urgent ? Qt.alpha(Colours.niri_urgent, 0.8) :
            floating ? Qt.alpha(Colours.niri_float, 0.4) :
            active ? Qt.alpha(Colours.pinkish, 0.6) :
            Qt.alpha(Colours.kindaGray, 0.6)
        // qmlformat on
        // opacity: 0.8

        Behavior on color {
            ColorAnimation {
                duration: 100
                easing.type: Easing.Linear
            }
        }

        // implicitWidth: focused ? 30 : 20
        // Behavior on implicitWidth {
        //     SmoothedAnimation {
        //         duration: 500
        //         easing.type: Easing.Linear
        //     }
        // }

        // implicitWidth: debugText.implicitWidth + 10
        // Text {
        //     id: debugText
        //     anchors.centerIn: parent
        //     text: windowItem.modelData.windowId + ":" + windowItem.modelData.layout.tileIndexInScrollingLayout + "x" + windowItem.modelData.layout.columnIndexInScrollingLayout
        //     color: "white"
        //     font.family: "JetBrainsMonoNFM"
        //     font.pixelSize: 14
        // }
    }
}

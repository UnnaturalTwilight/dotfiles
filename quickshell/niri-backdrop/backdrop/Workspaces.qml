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
    property int workspaceCount: 0
    ScriptModel {
        id: spaces
        values: {
            // filtering workspaces by output and removing extra empty workspaces
            let s = [...Niri.workspaces.filter(w => w.output === bgWorkspaces.screen?.name)];
            const firstEmptyIndex = s.findIndex(s => s.windows.length === 0);
            s = s.filter((s, i) => s.windows.length > 0 || i === firstEmptyIndex);
            bgWorkspaces.workspaceCount = s.length;
            return s;
        }
    }

    implicitWidth: workspaceLayout.implicitWidth + 32
    implicitHeight: workspaceLayout.implicitHeight + 32

    x: 40
    y: screen?.height - (40 + implicitHeight)

    RectangularShadow {
        id: shadowBox
        anchors.fill: workspaceLayout
        offset.x: 0
        offset.y: 0
        radius: workspaceLayout.height / 2
        blur: 8
        spread: 8
        color: Colours.shadow
    }

    RowLayout {
        id: workspaceLayout
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            id: repeater
            model: spaces

            WorkspaceItem {
                Layout.alignment: Qt.AlignCenter
            }
        }
    }

    component WorkspaceItem: Rectangle {
        id: workspaceItem
        required property NiriWorkspace modelData
        readonly property bool active: modelData?.isFocused ?? false
        readonly property bool empty: modelData?.windows.length === 0

        // radius: Math.min(width, height) / 2
        topLeftRadius: modelData.idx === 1 ? 50 : 8
        bottomLeftRadius: topLeftRadius
        topRightRadius: modelData.idx >= bgWorkspaces.workspaceCount ? 50 : 8
        bottomRightRadius: topRightRadius

        implicitWidth: Math.max(windowLayout.implicitWidth + 14, 36)
        implicitHeight: 36

        color: active ? Colours.power5 : Colours.polar2
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
                            // Placeholder object in order to use the windowItem to show an icon for empty workspaces
                            return [
                                {
                                    workspaceId: workspaceItem.modelData.workspaceId,
                                    empty: true
                                }
                            ];
                        }
                    }
                }

                WindowItem {
                    Layout.alignment: Qt.AlignCenter
                }
            }
        }
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
        required property var modelData // can be either a NiriWindow or a placeholder object for empty workspaces
        readonly property bool empty: modelData?.empty ?? false // if empty is true only active will be valid
        readonly property bool active: Niri.focusedWorkspace?.workspaceId === modelData?.workspaceId
        readonly property bool focused: Niri.focusedWindow?.windowId === modelData?.windowId && !Niri?.overviewOpened
        readonly property bool urgent: modelData?.isUrgent ?? false
        readonly property bool floating: modelData?.isFloating ?? false

        radius: 20
        implicitWidth: 20
        implicitHeight: 20

        color: {
            if (empty) {
                return "transparent";
            } else if (urgent) {
                return Colours.power2;
            } else if (floating) {
                if (active) {
                    return focused ? Colours.frost3 : Colours.frost1;
                } else {
                    return Colours.frost0;
                }
            } else if (active) {
                return focused ? Colours.mana4 : Colours.mana1;
            } else {
                return Colours.gray;
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 100
                easing.type: Easing.Linear
            }
        }

        Text {
            id: iconText
            visible: parent.empty
            text: "󰐙"
            color: parent.active ? Colours.mana1 : Colours.polar5
            font.family: Fonts.nerdMono
            font.pixelSize: 32
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
        }
    }
}

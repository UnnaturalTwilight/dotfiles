// ContextMenu.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.config

PopupWindow {
    id: menuWindow

    required property QsMenuHandle menuHandle
    property ContextMenu parentMenu: null
    property ContextMenu childMenu: null

    property int anchorX: 0
    property int anchorY: 0

    property bool icons: true

    anchor.window: overlayPanel
    anchor.rect.x: anchorX
    anchor.rect.y: anchorY

    implicitHeight: menuLayout.implicitHeight + 16 + 20

    color: "transparent"

    Loader {
        id: childMenuLoader
        active: false
    }

    Connections {
        target: childMenu

        function onMouseEnter() {
            menuWindow.open();
            menuWindow.mouseEnter();
        }
    }

    property bool menuOpen: false

    signal mouseEnter

    Rectangle {
        id: menuWindowBg
        anchors.fill: parent
        anchors.margins: 5
        color: Colours.polar1
        border.color: Colours.frost0
        border.width: 2
        radius: 12
        opacity: 0

        states: [
            State {
                name: "open"
                when: menuWindow.menuOpen
                PropertyChanges {
                    menuWindowBg.opacity: 1
                }
            },
            State {
                name: "closed"
                when: !menuWindow.menuOpen
                PropertyChanges {
                    menuWindowBg.opacity: 0
                }
            }
        ]

        transitions: [
            Transition {
                to: "closed"
                NumberAnimation {
                    properties: "opacity"
                    easing.type: Easing.InQuad
                    duration: 250
                }
            },
            Transition {
                to: "open"
                NumberAnimation {
                    properties: "opacity"
                    easing.type: Easing.OutQuad
                    duration: 50
                }
            }
        ]

        QsMenuOpener {
            id: menuOpener
            menu: menuWindow.menuHandle
        }

        ColumnLayout {
            id: menuLayout
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            Repeater {
                model: menuOpener.children

                Loader {
                    id: menuButtonLoader
                    required property QsMenuEntry modelData
                    Layout.fillWidth: true
                    sourceComponent: MenuEntry {
                        modelData: menuButtonLoader.modelData
                    }
                }
            }
        }
    }

    component MenuEntry: Item {
        id: entry
        required property QsMenuEntry modelData
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

        enabled: (!entry.modelData?.isSeparator && entry.modelData?.enabled) ?? false
        implicitHeight: entry.modelData?.isSeparator ? 4 : label.height
        property bool checked: entry.modelData?.checkState ?? false
        property alias hovered: menuEntryMouseArea.containsMouse

        MouseArea {
            id: menuEntryMouseArea
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: entry.enabled

            onEntered: {
                if (entry.modelData.hasChildren) {
                    childMenuLoader.setSource("ContextMenu.qml", {
                        menuHandle: entry.modelData,
                        parentMenu: menuWindow,
                        anchorX: menuWindow.anchorX + 100,
                        anchorY: menuWindow.anchorY + entry.mapToItem(menuWindowBg, 0, 0).y + entry.implicitHeight + 2,
                        implicitWidth: menuWindow.width - 105
                    });
                    childMenuLoader.active = true;
                    menuWindow.childMenu = childMenuLoader.item;
                    menuWindow.childMenu.open();
                } else if (childMenu) {
                    menuWindow.childMenu.closeSelf();
                }
            }

            onClicked: {
                entry.modelData.triggered();
            }
        }

        // Separator or Hover Background
        Rectangle {
            anchors.fill: parent
            anchors.margins: !entry.modelData?.isSeparator ? -3 : 0
            anchors.leftMargin: !entry.modelData?.isSeparator ? label.anchors.leftMargin - 5 : 10
            anchors.rightMargin: !entry.modelData?.isSeparator ? 0 : 10
            radius: 8
            color: !entry.modelData?.isSeparator ? entry.hovered ? Colours.highlight : "transparent" : Colours.polar2
        }

        // Content
        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
            // This is for Solaar since it uses spaces for indentation and looks weird when the text is wrapped
            text: {
                const l = entry.modelData?.text;
                if (l) {
                    const t = l.trim();
                    anchors.leftMargin = 5 + (l.length - t.length) * 5;
                    return t;
                } else {
                    return "...";
                }
            }
            color: parent.enabled ? Colours.text : Colours.snow0
            width: parent.width - 10 - (arrow.visible ? 26 : 0)
            wrapMode: entryIcon.visible ? Text.NoWrap : Text.WrapAtWordBoundaryOrAnywhere
            elide: Text.ElideRight
            font.family: Fonts.sans
            font.pixelSize: 16
            visible: !entry.modelData?.isSeparator
        }

        Image {
            id: entryIcon
            visible: menuWindow.icons && (entry.modelData?.icon ?? false)
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            height: label.contentWidth < parent.width * 0.7 ? label.lineCount * 20 : 20
            width: height
            source: entry.modelData?.icon ?? ""
        }

        SvgIcon {
            id: arrow
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            iconName: {
                if (entry.modelData?.hasChildren) {
                    return "more_horiz";
                }
                let base = entry.modelData?.buttonType === QsMenuButtonType.CheckBox ? "states/check-box_" : "states/radio-button_";
                return base + (entry.checked ? "checked" : "unchecked");
            }
            size: 20
            colour: entry.checked ? Colours.frost1 : Colours.gray
            visible: entry.modelData?.buttonType !== QsMenuButtonType.None || entry.modelData?.hasChildren
        }
    }

    HoverHandler {
        id: menuHover
        margin: 20

        onHoveredChanged: {
            if (hovered) {
                menuWindow.open();
                menuWindow.mouseEnter();
            } else {
                menuWindow.closeSelf();
            }
        }
    }

    Timer {
        id: debounceTimer
        interval: 250
        onTriggered: {
            menuWindow.close();
        }
    }

    function closeSelf(force = false) {
        if (menuHover.hovered && !force) {
            return;
        } else {
            menuOpen = false;
            debounceTimer.start();
        }
    }

    function open() {
        debounceTimer.stop();
        visible = true;
        menuOpen = true;
    }

    function close() {
        childMenuLoader.active = false;
        childMenu = null;
        visible = false;
        menuOpen = false;
        if (parentMenu) {
            parentMenu.closeSelf();
        }
    }
}

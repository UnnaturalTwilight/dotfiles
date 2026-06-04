// TrayMenu.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.config

PopupWindow {
    id: menuWindow

    required property QsMenuHandle menuHandle
    property TrayMenu parentMenu: null
    property TrayMenu childMenu: null

    property real anchorX: 0
    property real anchorY: 0

    anchor.window: startPanel
    anchor.rect.x: anchorX
    anchor.rect.y: anchorY

    implicitHeight: menuLayout.implicitHeight + 16

    color: "transparent"

    Loader {
        id: childMenuLoader
        active: false
    }

    property bool menuOpen: false

    Rectangle {
        id: menuWindowBg
        anchors.fill: parent
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
                    duration: 250
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
            hoverEnabled: entry.enabled

            onEntered: {
                if (entry.modelData.hasChildren) {
                    childMenuLoader.setSource("TrayMenu.qml", {
                        menuHandle: entry.modelData,
                        parentMenu: menuWindow,
                        anchorX: menuWindow.anchorX + 100,
                        anchorY: menuWindow.anchorY + entry.mapToItem(menuWindowBg, 0, 0).y + entry.implicitHeight,
                        implicitWidth: 300
                    });
                    childMenuLoader.active = true;
                    menuWindow.childMenu = childMenuLoader.item;
                    menuWindow.childMenu.open();
                }
            }

            onExited: {
                if (menuWindow.childMenu) {
                    menuWindow.childMenu.startSelfCloseTimer();
                }
            }

            onClicked: {
                entry.modelData.triggered();
                // reloadTrayMenu();
            }
        }

        // Separator or Hover Background
        Rectangle {
            anchors.fill: parent
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
            color: parent.enabled ? Colours.text : Colours.snow5
            width: parent.width - 10 - (arrow.visible ? 26 : 0) - (checkbox.visible ? 26 : 0)
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.family: Fonts.sans
            font.pixelSize: 16
            visible: !entry.modelData?.isSeparator
        }

        // This should probably not be text
        Text {
            id: arrow
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            anchors.right: parent.right
            anchors.rightMargin: 12
            text: entry.modelData?.hasChildren ? "󰦺" : ""
            font.family: Fonts.nerd
            font.pixelSize: 20
            color: Colours.gray
        }

        Rectangle {
            id: checkbox
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            width: label.font.pixelSize
            height: label.font.pixelSize
            radius: entry.modelData?.buttonType === QsMenuButtonType.CheckBox ? 4 : (parent.height - 6) / 2
            color: entry.checked ? Colours.power5 : Colours.polar5
            border.color: Qt.alpha(Colours.gray, 0.5)
            border.width: 2
            visible: entry.modelData?.buttonType !== QsMenuButtonType.None

            Text {
                anchors.centerIn: parent
                text: entry.modelData?.buttonType === QsMenuButtonType.CheckBox ? "" : ""
                font.family: Fonts.nerdMono
                font.pixelSize: 9
                color: Colours.text
                visible: entry.checked
            }
        }
    }

    HoverHandler {
        id: menuHover

        onHoveredChanged: {
            if (hovered) {
                menuWindow.stopSelfCloseTimer();
            } else {
                menuWindow.startSelfCloseTimer();
            }
        }
    }

    Timer {
        id: selfCloseTimer
        interval: 250
        repeat: false
        running: false
        onTriggered: menuWindow.closeSelf()
    }

    Timer {
        id: fadeOutTimer
        interval: 250
        repeat: false
        running: false
        onTriggered: {
            if (menuWindow.parentMenu) {
                menuWindow.parentMenu.destroyChild();
                menuWindow.parentMenu.closeSelf();
            } else {
                menuWindow.visible = false;
            }
        }
    }

    function closeSelf(force = false) {
        destroyChild();
        if (menuHover.hovered && !force) {
            return;
        } else {
            menuOpen = false;
            fadeOutTimer.start();
        }
    }

    function destroyChild() {
        if (childMenu) {
            childMenu.destroyChild();
            childMenuLoader.active = false;
            childMenu = null;
        }
    }

    function startSelfCloseTimer() {
        selfCloseTimer.start();
    }

    function stopSelfCloseTimer() {
        if (parentMenu) {
            parentMenu.stopSelfCloseTimer();
        }
        selfCloseTimer.stop();
    }

    function open() {
        visible = true;
        menuOpen = true;
    }

    function toggle() {
        if (visible) {
            closeSelf();
        } else {
            open();
        }
    }
}

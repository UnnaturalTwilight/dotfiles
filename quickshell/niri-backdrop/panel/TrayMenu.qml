// TrayMenu.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs

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

    Rectangle {
        id: menuWindowBg
        anchors.fill: parent
        color: Colours.polar1
        border.color: Colours.frost0
        border.width: 2
        radius: 12

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

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
        implicitHeight: entry.modelData?.isSeparator ? 6 : label.height
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
                        anchorX: menuWindow.anchor.rect.x + 100,
                        anchorY: menuWindow.anchor.rect.y + entry.mapToItem(menuWindowBg, 0, 0).y + entry.implicitHeight,
                        implicitWidth: 300
                    });
                    childMenuLoader.active = true;
                    menuWindow.childMenu = childMenuLoader.item;
                    menuWindow.childMenu.visible = true;
                }
            }

            onExited: {
                if (menuWindow.childMenu) {
                    menuWindow.childMenu.startSelfCloseTimer();
                }
            }

            onClicked: {
                entry.modelData.triggered();
                reloadTrayMenu();
            }
        }

        // Separator
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            radius: 6
            color: !entry.modelData?.isSeparator ? "transparent" : Colours.polar2
        }

        // Content
        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
            // This is for Solaar since it uses spaces for indentation and looks weird when the text is wrapped
            text: {
                let text = entry.modelData?.text;
                if (text && !entry.modelData?.isSeparator) {
                    while (text.startsWith(" ")) {
                        anchors.leftMargin += 5;
                        text = text.substring(1);
                    }
                    return text;
                } else {
                    return "Unknown";
                }
            }
            color: parent.enabled ? Colours.text : Colours.polar5
            width: parent.width - 10 - (arrow.visible ? 26 : 0) - (checkbox.visible ? 26 : 0)
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.family: "Noto Sans"
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
            font.family: "JetBrainsMonoMF"
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
                font.family: "JetBrainsMonoMFM"
                font.pixelSize: 9
                color: Colours.text
                visible: entry.checked
            }
        }

        Rectangle {
            radius: 8
            anchors.fill: parent
            color: entry.hovered ? Colours.highlight : "transparent"
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
        onTriggered: menuWindow.closeSelf()
    }

    function closeSelf(force = false) {
        destroyChild();
        if (menuHover.hovered) {
            return;
        }
        if (parentMenu) {
            parentMenu.destroyChild();
            parentMenu.closeSelf();
        } else {
            visible = false;
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
        menuWindowBg.opacity = 0;
    }

    function stopSelfCloseTimer() {
        if (parentMenu) {
            parentMenu.stopSelfCloseTimer();
        }
        selfCloseTimer.stop();
        menuWindowBg.opacity = 1;
    }

    function open() {
        menuWindowBg.opacity = 0;
        visible = true;
        menuWindowBg.opacity = 1;
    }

    function toggle() {
        if (visible) {
            closeSelf();
        } else {
            open();
        }
    }
}

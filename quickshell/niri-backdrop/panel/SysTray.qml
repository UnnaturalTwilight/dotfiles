// Systray.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services

Item {
    id: systray

    visible: SystemTray.items.values.length !== 0
    property int iconSize: 32
    property var menuWidth: 350

    property var activeMenu: null

    Layout.fillWidth: true
    implicitHeight: trayLayout.implicitHeight

    signal menuSwaped

    RowLayout {
        id: trayLayout
        anchors.centerIn: parent

        Rectangle {
            // space for 8 icons including the brightness tile
            Layout.preferredWidth: (10 - trayRepeater.count) * (systray.iconSize + 8)
        }

        Repeater {
            id: trayRepeater
            model: ScriptModel {
                values: [...SystemTray.items.values].sort((a, b) => systray.sortingFunction(a, b))
            }

            TrayIcon {}
        }
    }

    component TrayIcon: Rectangle {
        id: trayIcon
        required property SystemTrayItem modelData

        width: systray.iconSize + 8
        height: systray.iconSize + 8
        color: Colours.black // This is mostly to hide the sharp corners of the tailscale icon
        border.color: trayIconMouseArea.containsMouse ? Colours.power1 : Colours.polar2
        border.width: 2
        radius: 8

        Image {
            id: trayIconImage
            anchors.centerIn: parent
            source: systray.overrideAppIcon(trayIcon.modelData)
            sourceSize.width: width
            sourceSize.height: height
            width: systray.iconSize
            height: systray.iconSize
            fillMode: Image.PreserveAspectFit
        }

        Loader {
            id: trayMenuLoader
            anchors.fill: parent
            active: false
            sourceComponent: TrayMenu {
                id: trayMenu
                menuHandle: trayIcon.modelData.menu
                anchorX: screen.width - (30 + systray.menuWidth)
                anchorY: screen.height - (320 + implicitHeight)
                implicitWidth: systray.menuWidth
            }

            function reloadTrayMenu() {
                active = !active;
                active = !active;
            }

            Connections {
                target: systray

                function onMenuSwaped() {
                    if (systray.activeMenu === trayIcon.modelData) {
                        trayMenuLoader.active = true;
                    } else {
                        trayMenuLoader.item?.closeSelf();
                    }
                }
            }

            onVisibleChanged: {
                if (!visible) {
                    trayMenuLoader.item?.closeSelf();
                }
            }
        }

        MouseArea {
            id: trayIconMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onPressed: event => {
                systray.activeMenu = trayIcon.modelData;
                trayMenuLoader.active = true;
                systray.menuSwaped();
                if (event.buttons & Qt.LeftButton) {
                    if (trayIcon.modelData.onlyMenu) {
                        trayMenuLoader.item?.toggle();
                    } else {
                        trayIcon.modelData.activate();
                    }
                }
                if (event.buttons & Qt.RightButton) {
                    if (trayIcon.modelData.hasMenu) {
                        trayMenuLoader.item?.toggle();
                    } else {
                        trayIcon.modelData.activate();
                    }
                }
                if (event.buttons & Qt.MiddleButton) {
                    trayIcon.modelData.secondaryActivate();
                }
            }
            onExited: {
                trayMenuLoader.item?.startSelfCloseTimer();
            }
        }
    }

    function overrideAppIcon(app) {
        // console.log(app.id, app.title || app.tooltipTitle, app.icon);

        // This is the only field that discord populates with identifying info
        if (app.tooltipTitle === "Discord") {
            return Quickshell.iconPath("discord", app.icon);
        }

        // if (app.id === "blueman") {
        // return Quickshell.iconPath("bluetooth", app.icon);
        // }

        // This matches tailscale which doesn't have ANY static identifying info
        // if (app.id.startsWith("systray_")) {
        // Tailscale uses a dynamic icon that both isn't symbolic and doesn't have rounded corners
        // making it not match anything else
        // my icon theme doesn't have icon for it tho so I just live with it for now
        // }

        return app.icon;
    }

    function sortingFunction(a, b) {
        // Put pinned items first, then sort by title
        const idxA = sysTrayOrder(a);
        const idxB = sysTrayOrder(b);
        return idxA - idxB;
    }

    function sysTrayOrder(a) {
        // This is the order I want certain known apps to appear in the tray
        const order = ["nm-applet", "blueman", "tailscale", "systray_", "Windscribe", "indicator-solaar"];
        const index = order.findIndex(id => a.id.includes(id));
        return index === -1 ? Number.POSITIVE_INFINITY : index;
    }
}

// Systray.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.widgets

Item {
    id: systray

    property int iconSize: 32
    property var menuWidth: 360

    property var activeMenu: null

    Layout.fillWidth: true
    implicitHeight: trayLayout.implicitHeight

    signal menuSwaped

    Loader {
        id: menuLoader
        active: false
        sourceComponent: ContextMenu {
            id: trayMenu
            menuHandle: systray.activeMenu
            anchorX: screen.width - (10 + systray.menuWidth)
            anchorY: screen.height - (320 + implicitHeight)
            implicitWidth: systray.menuWidth
        }
    }

    RowLayout {
        id: trayLayout
        anchors.right: parent.right
        anchors.rightMargin: 16

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
        color: Colours.shadow
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

        MouseArea {
            id: trayIconMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onPressed: event => {
                systray.activeMenu = trayIcon.modelData.menu;
                menuLoader.active = true;
                systray.menuSwaped();
                if (event.buttons & Qt.LeftButton) {
                    if (trayIcon.modelData.onlyMenu) {
                        menuLoader.item?.open();
                    } else if (trayIcon.modelData.id === "Thunderbird") {
                        Quickshell.execDetached(["systemctl", "--user", "start", "thunderbird.service"]);
                    } else {
                        trayIcon.modelData.activate();
                    }
                }
                if (event.buttons & Qt.RightButton) {
                    if (trayIcon.modelData.hasMenu) {
                        menuLoader.item?.open();
                    } else {
                        trayIcon.modelData.activate();
                    }
                }
                if (event.buttons & Qt.MiddleButton) {
                    trayIcon.modelData.secondaryActivate();
                }
            }

            onExited: menuLoader.item?.closeSelf();
        }
    }

    function overrideAppIcon(app) {
        // console.log(app.id, app.title || app.tooltipTitle, app.icon);

        if (app.id == "Thunderbird") {
            return Quickshell.iconPath("thunderbird", true) || app.icon;
        } else if (app.id == "steam") {
            // IDK what is going on here but this causes
            // `~/.local/share/Steam/public/steam_tray_mono` to be used as the icon
            // its a better tray icon than what my theme provides so I'm not complaining
            return Quickshell.iconPath("steam", app.icon);
        } else if (app.id.includes("discord")) {
            return Quickshell.iconPath("discord", true) || app.icon;
        }

        return app.icon;
    }

    function sortingFunction(a, b) {
        // This is the order I want certain known apps to appear in the tray
        const order = ["nm-applet", "blueman", "tailscale", "Windscribe", "indicator-solaar", "Thunderbird", "discord", "steam"];
        const idxA = order.findIndex(id => a.id.includes(id));
        if (idxA === -1) return 1;
        const idxB = order.findIndex(id => b.id.includes(id));
        if (idxB === -1) return -1;
        return idxA - idxB;
    }
}

// SysTray.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs

Item {
    id: root

    Rectangle {
        id: trayBox
        implicitHeight: 40
        anchors.fill: parent
        color: "transparent"
        border.color: Qt.alpha(Colours.kindaGray, 0.5)
        border.width: 3
        radius: 12

        RowLayout {
            anchors.fill: parent
            anchors.margins: 5

            WrapperMouseArea {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.preferredWidth: 1000
                Layout.fillHeight: true
                Layout.fillWidth: true
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: "󰃟"
                    font.family: "JetBrainsMonoMFM"
                    font.pixelSize: 32
                    verticalAlignment: Text.AlignBottom
                    color: Colours.kindaGray
                }
            }

            Repeater {
                Layout.alignment: Qt.AlignCenter
                model: SystemTray.items

                delegate: TrayItem {}
            }

            Rectangle {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.preferredWidth: 1000
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: "transparent"
            }
        }
    }

    component TrayItem: Item {
        id: trayItem
        width: 32
        height: 32

        required property var modelData

        IconImage {
            anchors.fill: parent
            source: root.overrideAppIcon(trayItem.modelData)
            asynchronous: true
            mipmap: true
            // implicitSize: 32
        }

        MouseArea {
            anchors.fill: parent
            // cursorShape: Qt.PointingHandCursor
            onClicked: menu.open()
            onDoubleClicked: trayItem.modelData.activate()
        }

        QsMenuOpener {
            id: opener
            menu: trayItem.modelData?.menu ?? null
        }

        // Close the menu when the systray is hidden
        onVisibleChanged: {
            if (!visible) {
                menu.close();
            }
        }

        TrayMenu {
            id: menu
            // It will be clamped to the window width
            implicitWidth: 400
            y: 32 + 4

            Repeater {
                model: opener.children
                delegate: SysMenuItem {
                    id: menuItem

                    QsMenuOpener {
                        id: subopener
                        menu: menuItem.modelData
                    }

                    onHighlightedChanged: {
                        if (highlighted && menuItem.modelData?.hasChildren) {
                            submenu.open();
                        } else {
                            Qt.callLater(submenu.close);
                        }
                    }

                    TrayMenu {
                        id: submenu
                        implicitWidth: 250
                        y: menuItem.height
                        x: menuItem.width - 250

                        Repeater {
                            model: subopener.children
                            delegate: SysMenuItem {}
                        }
                    }
                }
            }
        }
    }

    component TrayMenu: Menu {
        id: trayMenu
        font.pixelSize: 16
        font.family: "JetBrainsMonoNFM"
        clip: true

        margins: 40
        padding: 5
        spacing: 3

        background: Rectangle {
            id: trayMenuBg
            radius: 12
            color: Colours.bgGray
            border.color: Colours.niri_float
            border.width: 3
        }

        contentItem: ListView {
            implicitHeight: contentHeight
            model: trayMenu.contentModel
            interactive: implicitHeight > trayMenu.implicitHeight - 2 * trayMenu.padding
            clip: true
            spacing: trayMenu.spacing
        }
    }

    function overrideAppIcon(app) {
        // console.log(app.id, app.title || app.tooltipTitle, app.icon);

        // This is the only field that discord populates with identifying info
        if (app.tooltipTitle === "Discord") {
            return Quickshell.iconPath("discord", app.icon);
        }

        // This matches tailscale which doesn't have ANY static identifying info
        // if (app.id.startsWith("systray_")) {
        // Tailscale uses a dynamic icon that both isn't symbolic and doesn't have rounded corners
        // making it not match anything else
        // my icon theme doesn't have icon for it tho so I just live with it for now
        // }

        return app.icon;
    }
}

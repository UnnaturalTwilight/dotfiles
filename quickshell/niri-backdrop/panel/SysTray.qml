// SysTray.qml

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
            anchors.centerIn: parent
            anchors.margins: 5

            Repeater {
                model: SystemTray.items

                delegate: TrayItem {}
            }
        }
    }

    component TrayItem: Item {
        id: trayItem
        width: 32
        height: 32

        required property var modelData

        IconImage {
            anchors.centerIn: parent
            source: trayItem.modelData.icon
            asynchronous: true
            mipmap: true
            implicitSize: 32
        }

        MouseArea {
            anchors.fill: parent
            onClicked: menu.open()
            onDoubleClicked: trayItem.modelData.activate()
        }

        QsMenuOpener {
            id: opener
            menu: trayItem.modelData?.menu ?? null
        }

        Menu {
            id: menu
            property var entryData: null
            font.pixelSize: 16
            font.family: "JetBrainsMonoNFM"
            // It will be clamped to the window width
            implicitWidth: 900
            clip: true

            y: 32 + 4
            margins: 40
            padding: 5

            background: Rectangle {
                id: menuBg
                radius: 12
                color: Colours.bgGray
                border.color: Colours.niri_float
                border.width: 3
            }

            contentItem: ListView {
                implicitHeight: contentHeight
                model: menu.contentModel
                interactive: implicitHeight > menu.implicitHeight - 2 * menu.padding
                clip: true
                spacing: menu.spacing
            }

            Repeater {
                model: opener.children
                delegate: SysMenuItem {
                }
            }
        }
    }
}

// Panels.qml

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services
import qs.panel

Item {
    id: panels
    // required property var screen
    property int margin: 10
    property int radius: 12
    property int buttonWidth: 60

    anchors {
        top: parent.top
        right: parent.right
        bottom: parent.bottom
        margins: margin
    }
    implicitWidth: 550 - (2 * margin)

    property Region blurZone: Region {
        Region {
            item: tabContentZone
            radius: panels.radius
        }
        Region {
            item: tileZone
            radius: panels.radius
        }
    }

    property Region maskZone: Region {
        Region {
            item: statusZone
        }
        Region {
            x: panels.x + panels.buttonWidth
            y: panels.y - panels.margin
            width: tileZone.width + (3 * panels.margin)
            height: panels.height + (2 * panels.margin)
        }
        Region {
            x: panels.x - (panels.margin / 2)
            y: tabButtons.y - (panels.margin)
            width: panels.buttonWidth + (2 * panels.margin)
            height: tabButtons.implicitHeight + (3 * panels.margin)
        }
        Region {
            x: panels.x - (panels.margin / 2)
            y: powerButtons.y
            width: panels.buttonWidth + (2 * panels.margin)
            height: powerButtons.implicitHeight + (2 * panels.margin)
        }
    }

    Statusline {
        id: statusZone
        margin: panels.margin
        radius: panels.radius

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            leftMargin: -40 //panels.margin
            // rightMargin: panels.margin
        }
    }

    TabButtons {
        id: tabButtons
        buttonSize: panels.buttonWidth
        bgColour: Colours.power5

        anchors {
            top: statusZone.bottom
            topMargin: panels.margin * 2
            left: parent.left
        }
    }

    StackLayout {
        id: tabContentZone
        anchors {
            top: statusZone.bottom
            left: powerButtons.right
            right: statusZone.right
            bottom: tileZone.top
            margins: panels.margin
            rightMargin: 0
        }

        currentIndex: System.panelTab

        NotifPane {
            radius: panels.radius
        }

        NetworkPane {
            radius: panels.radius
        }

        Rectangle {
            color: Colours.aurora3
            implicitWidth: 200
            implicitHeight: 200
            radius: panels.radius
        }

        DebugPane {}
    }

    TilePane {
        id: tileZone
        anchors {
            left: powerButtons.right
            leftMargin: panels.margin
            right: statusZone.right
            // rightMargin: panels.margin
            bottom: parent.bottom
            // bottomMargin: panels.margin
        }
        radius: panels.radius
        margin: panels.margin
    }

    PowerButtons {
        id: powerButtons
        buttonSize: panels.buttonWidth
        colour: Colours.power5
        borderColour: Colours.frost0

        anchors {
            bottom: parent.bottom
            bottomMargin: panels.margin * 1.5
            left: parent.left
        }
    }
}

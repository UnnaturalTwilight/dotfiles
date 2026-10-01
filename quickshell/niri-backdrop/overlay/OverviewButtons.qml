// OverviewButtons.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services.niri
import qs.widgets

Item {
    id: root

    property bool drawingTablet: false
    property int popupWidth: 400
    property int popupHeight: 50
    property int radius: 10

    property bool shown: Niri.overviewOpened

    property Region maskZone: Region {
        Region {
            item: background
        }
    }

    states: [
        State {
            name: "hidden"
            when: !root.shown
            PropertyChanges {
                background.y: -100
                background.opacity: 0
            }
        },
        State {
            name: "shown"
            when: root.shown
            PropertyChanges {
                background.y: 0
                background.opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            to: "hidden"
            NumberAnimation {
                properties: "y,opacity"
                easing.type: Easing.InQuad
                duration: 250
            }
        },
        Transition {
            to: "shown"
            NumberAnimation {
                properties: "y,opacity"
                easing.type: Easing.OutQuad
                duration: 250
            }
        }
    ]

    Rectangle {
        id: background
        opacity: 0

        implicitWidth: root.popupWidth
        implicitHeight: root.popupHeight
        radius: root.radius
        color: Colours.power5
        border.color: Colours.frost0
        border.width: 2

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 10
                rightMargin: 10
            }

            FlatButton {
                text: "Restart OpenTabletDriver"

                onClicked: {
                    Quickshell.execDetached(["systemctl", "--user", "restart", "opentabletdriver.service"]);
                }
            }

            FlatButton {
                text: "Apps"
                implicitWidth: 32
                implicitHeight: 32

                contentItem: SvgIcon {
                    iconName: "apps"
                    colour: parent.hovered ? Colours.snow2 : Colours.snow0
                }

                onClicked: Quickshell.execDetached(["walker", "--height", "400",])
            }

            FlatButton {
                text: "Fullscreen"
                implicitWidth: 32
                implicitHeight: 32

                contentItem: SvgIcon {
                    iconName: "fullscreen"
                    colour: parent.hovered ? Colours.snow2 : Colours.snow0
                }

                onClicked: Niri.send({"Action":{"FullscreenWindow":{"id":null}}})
            }

            FlatButton {
                text: "Close"
                implicitWidth: 32
                implicitHeight: 32

                contentItem: SvgIcon {
                    iconName: "close"
                    colour: parent.hovered ? Colours.snow2 : Colours.snow0
                }

                onClicked: Niri.send({"Action":{"CloseWindow":{"id":null}}})
            }
        }
    }
}

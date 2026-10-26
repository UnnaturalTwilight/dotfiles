// TabButtons.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.config
import qs.services
import qs.widgets

Item {
    id: tabs

    property int buttonSize: 60
    property color bgColour: Colours.power5
    property color bgColourHover: Colours.highlight
    property color borderColour: Colours.frost0
    property color borderColourChecked: Colours.frost2
    property color fgColour: Colours.gray
    property color activeColour: Colours.power1

    implicitHeight: tabList.height

    ColumnLayout {
        id: tabList
        spacing: 10
        Layout.alignment: Qt.AlignCenter

        Tab {
            text: "notifications"
            iconName: "symbols/notifications"
            checked: System.panelTab === 0
            onClicked: System.panelTab = 0
        }

        Tab {
            text: "network"
            iconName: "network/wifi_gear"
            checked: System.panelTab === 1
            onClicked: System.panelTab = 1
        }

        Tab {
            text: "apps"
            iconName: "symbols/apps"
            checked: System.panelTab === 2
            onClicked: System.panelTab = 2
        }

        Tab {
            visible: System.debugMode
            text: "debug"
            iconName: "symbols/bug"
            checked: System.panelTab === 3
            onClicked: System.panelTab = 3
        }
    }

    component Tab: RadioButton {
        id: radioButton
        required property string iconName

        implicitHeight: tabs.buttonSize
        implicitWidth: tabs.buttonSize
        //property bool attached: !checked
        // Layout.leftMargin: attached ? 10 : 0

        contentItem: SvgIcon {
            iconName: radioButton.iconName
            size: tabs.buttonSize * 0.8
            colour: radioButton.hovered ? tabs.activeColour : tabs.fgColour
        }

        background: Rectangle {
            anchors.fill: parent
            //anchors.rightMargin: attached ? -12 : 0
            radius: tabs.buttonSize / 4
            // topRightRadius: !attached ? radius : 0
            // bottomRightRadius: !attached ? radius : 0
            color: tabs.bgColour
            border.color: checked ? tabs.borderColourChecked : tabs.borderColour
            border.width: checked ? 2.5 : 2

            Rectangle {
                anchors.fill: parent
                color: radioButton.hovered ? tabs.bgColourHover : "transparent"
                radius: parent.radius
                topRightRadius: parent.topRightRadius
                bottomRightRadius: parent.bottomRightRadius
            }

            // Behavior on anchors.rightMargin {
            //     NumberAnimation {
            //         duration: 100
            //     }
            // }

            // Behavior on topRightRadius {
            //     NumberAnimation {
            //         duration: 100
            //     }
            // }

            // Behavior on bottomRightRadius {
            //     NumberAnimation {
            //         duration: 100
            //     }
            // }

            Behavior on border.color {
                ColorAnimation {
                    duration: 50
                }
            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 100
                }
            }
        }

        indicator: null
    }
}

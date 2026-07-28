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
    property color fgColour: Colours.gray
    property color activeColour: Colours.power1

    implicitHeight: tabList.height

    property alias activeTab: tabButtonGroup.checkedButton
    property Region blurZone: Region {
        regions: blurRegions.instances
    }

    Variants {
        id: blurRegions
        model: {
            tabList.visibleChildren;
        }

        delegate: Region {
            required property Item modelData
            item: modelData
            radius: tabs.buttonSize / 4
        }
    }

    ButtonGroup {
        id: tabButtonGroup
        buttons: tabList.children
        exclusive: true
        onClicked: button => {
            console.log("Panel Tab:", button.text);
            switch (button.text) {
            case 'notifications':
                System.panelTab = 0;
                break;
            case 'network':
                System.panelTab = 1;
                break;
            case 'apps':
                System.panelTab = 2;
                break;
            default:
                System.panelTab = 3;
                break;
            }
        }
    }

    ColumnLayout {
        id: tabList
        spacing: 10
        Layout.alignment: Qt.AlignCenter

        Tab {
            text: "notifications"
            iconName: "notifications"
        }

        Tab {
            text: "network"
            iconName: "network/wifi_gear"
        }

        Tab {
            text: "apps"
            iconName: "apps"
        }

        Tab {
            visible: System.debugMode
            text: "debug"
            iconName: "bug"
        }
    }

    component Tab: RadioButton {
        id: radioButton
        required property string iconName

        implicitHeight: tabs.buttonSize
        implicitWidth: tabs.buttonSize

        contentItem: SvgIcon {
            iconName: radioButton.iconName
            size: tabs.buttonSize * 0.8
            colour: radioButton.hovered ? tabs.activeColour : tabs.fgColour
        }

        background: Rectangle {
            anchors.fill: parent
            radius: tabs.buttonSize / 4
            color: tabs.bgColour
            border.color: tabs.borderColour
            border.width: 2

            Rectangle {
                anchors.fill: parent
                color: radioButton.hovered ? tabs.bgColourHover : "transparent"
                radius: tabs.buttonSize / 4
            }
        }

        indicator: null
    }
}

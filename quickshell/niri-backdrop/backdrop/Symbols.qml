// Symbols.qml
import QtQuick
import QtQuick.Layouts

import qs.config
import qs.services
import qs.widgets

Item {
    id: bgSymbols
    required property var screen

    implicitWidth: sysLayout.implicitWidth
    implicitHeight: sysLayout.implicitHeight

    x: screen?.width - (50 + implicitWidth)
    y: screen?.height - (40 + implicitHeight)

    RowLayout {
        id: sysLayout
        spacing: 20

        Symbol {
            iconName: Audio.icon
            iconOpacity: Audio.muted ? 0.5 : 1.0
            iconSize: Audio.extraProps.iconDisplaySize
            barValue: Audio.volume
            barActive: !Audio.muted
        }

        Symbol {
            iconName: Battery.icons[Battery.iconIdx]
            iconSize: 96
            barValue: Battery.value
        }
    }

    component Symbol : Item {
        id: symbolRoot
        Layout.preferredWidth: 60
        Layout.fillHeight: true

        property alias iconName: symbolIcon.iconName
        property alias iconOpacity: symbolIcon.opacity
        property alias iconSize: symbolIcon.size

        property alias barValue: symbolBar.value
        property alias barActive: symbolBar.active

        SvgIcon {
            id: symbolIcon
            colour: Colours.gray
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: symbolBar.top
            anchors.bottomMargin: -4
            height: size + 2
        }

        PercentBar {
            id: symbolBar
            Layout.alignment: Qt.AlignCenter
            implicitWidth: 60
            implicitHeight: 10
            anchors.horizontalCenter: symbolIcon.horizontalCenter
            anchors.bottom: parent.bottom
        }
    }
}

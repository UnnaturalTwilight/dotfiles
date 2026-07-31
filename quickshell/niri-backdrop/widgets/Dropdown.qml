// Dropdown.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import qs.config

ComboBox {
    id: control
    textRole: "text"
    valueRole: "value"
    property string iconRole: "icon"

    property int radius: 4
    font.pixelSize: 16
    font.family: Fonts.mono
    font.bold: hovered
    hoverEnabled: true

    contentItem: Text {
        text: control.displayText
        font: control.font
        color: control.hovered ? Colours.white : Colours.snow2
        rightPadding: control.indicator.width + control.spacing
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // TODO: SVG/Canvas/Shape
    indicator: Text {
        id: indicatorText
        text: "󰕏"
        font.pixelSize: 16
        font.bold: true
        x: control.width - width - control.rightPadding
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        color: control.hovered ? Colours.white : Colours.gray
        width: 12
    }
    rightPadding: 2

    background: Rectangle {
        color: control.hovered ? Colours.highlight : Colours.shadow
        radius: control.radius
    }

    popup: Popup {
        y: 0
        width: parent.width
        height: contentItem.implicitHeight + 6
        padding: 3

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
        }

        background: Rectangle {
            color: Colours.polar1
            border.color: Colours.frost0
            border.width: 2
            radius: control.radius * 1.5
        }
    }

    delegate: ItemDelegate {
        id: delegate
        required property var model
        required property int index
        highlighted: control.highlightedIndex === index
        width: control.width

        contentItem: Text {
            text: delegate.model[control.textRole]
            color: Colours.white
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: delegate.highlighted ? Colours.highlight : "transparent"
            width: parent.width - 6
            radius: control.radius

            SvgIcon {
                anchors.right: parent.right
                anchors.rightMargin: -12
                anchors.verticalCenter: parent.verticalCenter
                iconName: delegate.model[control.iconRole] ?? "unknown"
                size: 48
                scale: 0.5
                colour: Colours.snow0
                visible: delegate.model[control.iconRole] ?? false
            }
        }
    }
}

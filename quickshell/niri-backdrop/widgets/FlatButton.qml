// FlatButton.qml

import QtQuick
import QtQuick.Controls

import qs.config

Button {
    id: control

    text: "Action"
    font.family: Fonts.mono
    property int radius: 4

    hoverEnabled: enabled

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.hovered ? Colours.white : Colours.snow2
        opacity: control.enabled ? 1 : 0.6
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        color: control.hovered ? Colours.highlight : Colours.shadow
        radius: control.radius
    }
}

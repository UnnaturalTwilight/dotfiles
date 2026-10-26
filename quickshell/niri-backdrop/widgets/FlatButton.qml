// FlatButton.qml

import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl

import qs.config

Button {
    id: control

    text: "Action"
    font.family: Fonts.mono
    property int radius: 4
    hoverEnabled: enabled

    /* Defaults from Button */
    // padding: 6
    // horizontalPadding: padding + 2
    // spacing: 6

    property int iconSize: 24
    property string iconName: "unknown"

    /* Can be one of "icon", "text", or "both" */
    property string mode: "text"
    display: mode === "icon" ? AbstractButton.IconOnly : mode === "both" ? AbstractButton.IconOnly | AbstractButton.TextOnly : AbstractButton.TextOnly

    icon {
        source: Quickshell.env("XDG_CONFIG_HOME") + "/assets/Icons/" + iconName + ".svg"
        height: iconSize
        width: iconSize
    }

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        defaultIconColor: control.hovered ? Colours.snow2 : Colours.snow0
        opacity: control.enabled ? 1 : 0.6
        text: control.text
        font: control.font
        color: control.hovered ? Colours.white : Colours.snow2

        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }
    }

    background: Rectangle {
        color: control.hovered ? Colours.highlight : Colours.shadow
        radius: control.radius
    }
}

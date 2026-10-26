// FlatButton.qml

import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl

import qs.config

Button {
    id: control

    // TODO! Tooltips
    text: "Action"
    font.family: Fonts.mono
    property int radius: 4
    hoverEnabled: enabled

    /* Defaults from Button */
    // padding: 6
    // horizontalPadding: padding + 2
    // spacing: 6

    /// svg icon name from the $XDG_CONFIG_HOME/assets/Icons/ directory
    /// Ignored if `mode` is not "icon" or "both"
    property string iconName: "unknown"
    property int iconSize: 24

    /// Can be one of "icon", "text", "both", or "checkbox". Unknown values default to "text"
    property string mode: "text"
    display: {
        control.mode === "icon" ? AbstractButton.IconOnly :
        (control.mode === "both" || control.mode === "checkbox") ? AbstractButton.TextBesideIcon :
        AbstractButton.TextOnly
    }

    /// Whether the button is checked. Ignored if `mode` is not "checkbox"
    checked: false

    icon {
        source: {
            const icon = control.mode === "checkbox" ? ("states/check-box_" + (control.checked ? "checked" : "unchecked")) : control.iconName
            Quickshell.env("XDG_CONFIG_HOME") + "/assets/Icons/" + icon + ".svg"
        }
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

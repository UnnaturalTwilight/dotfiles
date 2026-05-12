// SvgIcon.qml
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.VectorImage
import QtQuick.Effects

VectorImage {
    id: root

    property string iconName: "close"
    source: {
        return Quickshell.env("XDG_CONFIG_HOME") + "/assets/Icons/" + iconName + ".svg";
    }

    property int size: 24
    property color colour: "white"

    width: size
    height: size
    fillMode: VectorImage.PreserveAspectFit
    preferredRendererType: VectorImage.CurveRenderer

    layer.enabled: true
    layer.effect: MultiEffect {
        colorization: 1.0
        colorizationColor: root.colour
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.Linear
        }
    }
}

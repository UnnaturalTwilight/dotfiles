// SvgIcon.qml

import Quickshell
import QtQuick
import QtQuick.VectorImage

VectorImage {
    id: root

    property string iconName: "close"
    source: {
        return Quickshell.env("XDG_CONFIG_HOME") + "/assets/Icons/" + iconName + ".svg";
    }

    property int size: 24

    width: size
    height: size
    fillMode: VectorImage.PreserveAspectFit
    preferredRendererType: VectorImage.CurveRenderer

    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.Linear
        }
    }
}

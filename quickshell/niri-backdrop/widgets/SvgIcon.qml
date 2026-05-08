// SvgIcon.qml

import Quickshell
import QtQuick

Image {
    id: root

    property string iconName: "close"
    source: {
        return Quickshell.env("XDG_CONFIG_HOME") + "/assets/Icons/" + iconName + ".svg";
    }

    property int size: 24

    width: size
    height: size
    sourceSize: Qt.size(width, height)
    fillMode: Image.PreserveAspectFit

    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.Linear
        }
    }
}

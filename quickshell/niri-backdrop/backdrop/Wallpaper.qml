// Wallpaper.qml
import Quickshell
import QtQuick

Item {
    id: bgWallpaper
    required property var screen

    anchors.fill: parent

    Image {
        anchors.fill: parent
        source: Quickshell.env("XDG_CONFIG_HOME") + "/assets/niri-wallpaper.jpg"
        fillMode: Image.PreserveAspectCrop
        retainWhileLoading: true
        asynchronous: true
    }
}

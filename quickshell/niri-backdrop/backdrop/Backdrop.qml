// Backdrop.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.services

PanelWindow {
    id: bgPanel
    screen: modelData
    property var modelData

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "backdrop-qs-" + modelData.name
    color: "black"

    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }

    Image {
        anchors.fill: parent
        source: Quickshell.env("XDG_CONFIG_HOME") + "/assets/niri-wallpaper.jpg"
        fillMode: Image.PreserveAspectCrop
        retainWhileLoading: true
        asynchronous: true
    }

    Clock {
        screen: bgPanel.modelData
    }

    Loader {
        id: workspacesLoader
        sourceComponent: Workspaces {
            screen: bgPanel.modelData
        }
        asynchronous: true
        visible: status === Loader.Ready
        active: false
    }

    Loader {
        id: symbolsLoader
        sourceComponent: Symbols {
            screen: bgPanel.modelData
        }
        asynchronous: true
        visible: status == Loader.Ready
        active: bgPanel.modelData === System.primaryScreen
    }
}

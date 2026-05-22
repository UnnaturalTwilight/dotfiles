// Backdrop.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.utils

Scope {
    id: root

    property var modelData

    PanelWindow {
        id: bgPanel
        screen: root.modelData

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "backdrop-qs-" + root.modelData.name
        color: "black"

        anchors {
            top: true
            right: true
            left: true
            bottom: true
        }

        Wallpaper {
            screen: root.modelData
        }
    
        Clock {
            screen: root.modelData
        }

        Loader {
            id: workspacesLoader
            sourceComponent: Workspaces {
                screen: root.modelData
            }
            asynchronous: true
            visible: status === Loader.Ready
        }

        Loader {
            id: symbolsLoader
            sourceComponent: Symbols {
                screen: root.modelData
            }
            asynchronous: true
            visible: status == Loader.Ready
            active: root.modelData === System.primaryScreen
        }
    }
}

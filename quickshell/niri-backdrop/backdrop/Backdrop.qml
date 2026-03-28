// Backdrop.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.utils
import qs.backdrop

Item {
    id: root

    property var modelData

    PanelWindow {
        id: bgPanel
        screen: root.modelData

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "backdrop-qs-items"
        color: "transparent"
        surfaceFormat.opaque: false

        anchors {
            top: true
            right: true
            left: true
            bottom: true
        }

        Loader {
            id: clockLoader
            sourceComponent: Clock {
                screen: root.modelData
            }
            asynchronous: true
            visible: status === Loader.Ready
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

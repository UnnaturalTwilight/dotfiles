// Overlay.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.services.notifications

PanelWindow {
    id: overlayPanel
    screen: modelData
    property var modelData

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "overlay-qs-" + modelData.name
    color: "transparent"
    surfaceFormat.opaque: false

    anchors {
        top: true
        right: true
        left: true
        bottom: true
    }

    mask: Region {
        item: notificationStack.contentItem
        radius: 20
    }

    ListView {
        id: notificationStack

        x: overlayPanel.modelData?.width - (40 + implicitWidth)
        y: 40
        implicitWidth: 400
        implicitHeight: overlayPanel.modelData?.height - 40
        spacing: 10

        interactive: false

        model: ScriptModel {
            values: NotifServer.list.filter(notif => notif.onscreen)
        }
        delegate: Notification {}

        add: Transition {
            NumberAnimation {
                properties: "x"
                from: 500
                duration: 250
                easing.type: Easing.OutQuad
            }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 250
                    easing.type: Easing.InQuad
                }
                NumberAnimation {
                    properties: "x"
                    to: 500
                    duration: 250
                    easing.type: Easing.InQuad
                }
            }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

    BackgroundEffect.blurRegion: blurZone

    Region {
        id: blurZone
        regions: blurRegions.instances
    }

    Variants {
        id: blurRegions
        model: {
            const zones = notificationStack.contentItem.visibleChildren.filter(child => child instanceof Rectangle);
            return zones;
        }

        delegate: Region {
            required property Item modelData
            item: modelData
            radius: 20
        }
    }
}

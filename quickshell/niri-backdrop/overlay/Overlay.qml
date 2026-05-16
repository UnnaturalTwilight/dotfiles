// Overlay.qml
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import qs.utils.notify

Item {
    id: overlayRoot

    property var modelData

    PanelWindow {
        id: overlayPanel
        screen: overlayRoot.modelData

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "overlay-qs-" + overlayRoot.modelData.name
        color: "transparent"
        surfaceFormat.opaque: false

        anchors {
            top: true
            right: true
            left: true
            bottom: true
        }

        mask: Region {
            item: notificationStack
        }

        BackgroundEffect.blurRegion: blurZone

        ColumnLayout {
            id: notificationStack
            spacing: 10

            implicitWidth: 400
            implicitHeight: childrenRect.height

            x: overlayRoot.modelData?.width - (40 + implicitWidth)
            y: 40

            Repeater {
                model: Notify.onscreen

                Notification {}
            }

            Rectangle {
                id: fixZone
            }
        }

        Region {
            id: blurZone
            regions: blurRegions.instances
        }

        Variants {
            id: blurRegions
            model: {
                const zones = notificationStack.visibleChildren.filter(child => child instanceof Rectangle);
                return zones;
            }

            delegate: Region {
                required property Item modelData
                item: modelData
                radius: 20
            }
        }
    }
}
